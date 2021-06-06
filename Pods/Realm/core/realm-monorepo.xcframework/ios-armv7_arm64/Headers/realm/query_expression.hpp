/*************************************************************************
 *
 * Copyright 2016 Realm Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **************************************************************************/

/*
This file lets you write queries in C++ syntax like: Expression* e = (first + 1 / second >= third + 12.3);

Type conversion/promotion semantics is the same as in the C++ expressions, e.g float + int > double == float +
(float)int > double.


Grammar:
-----------------------------------------------------------------------------------------------------------------------
    Expression:         Subexpr2<T>  Compare<Cond, T>  Subexpr2<T>
                        operator! Expression

    Subexpr2<T>:        Value<T>
                        Columns<T>
                        Subexpr2<T>  Operator<Oper<T>  Subexpr2<T>
                        power(Subexpr2<T>) // power(x) = x * x, as example of unary operator

    Value<T>:           T

    Operator<Oper<T>>:  +, -, *, /

    Compare<Cond, T>:   ==, !=, >=, <=, >, <

    T:                  bool, int, int64_t, float, double, StringData


Class diagram
-----------------------------------------------------------------------------------------------------------------------
Subexpr2
    void evaluate(size_t i, ValueBase* destination)

Compare: public Subexpr2
    size_t find_first(size_t start, size_t end)     // main method that executes query

    unique_ptr<Subexpr2> m_left;                               // left expression subtree
    unique_ptr<Subexpr2> m_right;                              // right expression subtree

Operator: public Subexpr2
    void evaluate(size_t i, ValueBase* destination)
    unique_ptr<Subexpr2> m_left;                               // left expression subtree
    unique_ptr<Subexpr2> m_right;                              // right expression subtree

Value<T>: public Subexpr2
    void evaluate(size_t i, ValueBase* destination)
    T m_v[8];

Columns<T>: public Subexpr2
    void evaluate(size_t i, ValueBase* destination)
    SequentialGetter<T> sg;                         // class bound to a column, lets you read values in a fast way
    Table* m_table;

class ColumnAccessor<>: public Columns<double>


Call diagram:
-----------------------------------------------------------------------------------------------------------------------
Example of 'table.first > 34.6 + table.second':

size_t Compare<Greater>::find_first()-------------+
         |                                        |
         |                                        |
         |                                        |
         +--> Columns<float>::evaluate()          +--------> Operator<Plus>::evaluate()
                                                                |               |
                                               Value<float>::evaluate()    Columns<float>::evaluate()

Operator, Value and Columns have an evaluate(size_t i, ValueBase* destination) method which returns a Value<T>
containing 8 values representing table rows i...i + 7.

So Value<T> contains 8 concecutive values and all operations are based on these chunks. This is
to save overhead by virtual calls needed for evaluating a query that has been dynamically constructed at runtime.


Memory allocation:
-----------------------------------------------------------------------------------------------------------------------
Subexpressions created by the end-user are stack allocated. They are cloned to the heap when passed to UnaryOperator,
Operator, and Compare. Those types own the clones and deallocate them when destroyed.


Caveats, notes and todos
-----------------------------------------------------------------------------------------------------------------------
    * Perhaps disallow columns from two different tables in same expression
    * The name Columns (with s) an be confusing because we also have Column (without s)
    * We have Columns::m_table, Query::m_table and ColumnAccessorBase::m_table that point at the same thing, even with
      ColumnAccessor<> extending Columns. So m_table is redundant, but this is in order to keep class dependencies and
      entanglement low so that the design is flexible (if you perhaps later want a Columns class that is not dependent
      on ColumnAccessor)

Nulls
-----------------------------------------------------------------------------------------------------------------------
First note that at array level, nulls are distinguished between non-null in different ways:
String:
    m_data == 0 && m_size == 0

Integer, Bool stored in ArrayIntNull:
    value == get(0) (entry 0 determins a magic value that represents nulls)

Float/double:
    null::is_null(value) which tests if value bit-matches one specific bit pattern reserved for null

The Columns class encapsulates all this into a simple class that, for any type T has
    evaluate(size_t index) that reads values from a column, taking nulls in count
    get(index)
    set(index)
    is_null(index)
    set_null(index)
*/

#ifndef REALM_QUERY_EXPRESSION_HPP
#define REALM_QUERY_EXPRESSION_HPP

#include <realm/array_timestamp.hpp>
#include <realm/array_binary.hpp>
#include <realm/array_string.hpp>
#include <realm/array_backlink.hpp>
#include <realm/array_list.hpp>
#include <realm/array_key.hpp>
#include <realm/array_bool.hpp>
#include <realm/array_fixed_bytes.hpp>
#include <realm/column_integer.hpp>
#include <realm/column_type_traits.hpp>
#include <realm/table.hpp>
#include <realm/index_string.hpp>
#include <realm/query.hpp>
#include <realm/list.hpp>
#include <realm/set.hpp>
#include <realm/query_value.hpp>
#include <realm/metrics/query_info.hpp>
#include <realm/util/optional.hpp>
#include <realm/util/serializer.hpp>

#include <numeric>
#include <algorithm>

// Normally, if a next-generation-syntax condition is supported by the old query_engine.hpp, a query_engine node is
// created because it's faster (by a factor of 5 - 10). Because many of our existing next-generation-syntax unit
// unit tests are indeed simple enough to fallback to old query_engine, query_expression gets low test coverage. Undef
// flag to get higher query_expression test coverage. This is a good idea to try out each time you develop on/modify
// query_expression.

#define REALM_OLDQUERY_FALLBACK 1

namespace realm {

template <class T>
T minimum(T a, T b)
{
    return a < b ? a : b;
}

template <class T>
struct Plus {
    T operator()(T v1, T v2) const
    {
        return v1 + v2;
    }
    static std::string description()
    {
        return "+";
    }
    typedef T type;
};

template <class T>
struct Minus {
    T operator()(T v1, T v2) const
    {
        return v1 - v2;
    }
    static std::string description()
    {
        return "-";
    }
    typedef T type;
};

template <class T>
struct Div {
    T operator()(T v1, T v2) const
    {
        return v1 / v2;
    }
    static std::string description()
    {
        return "/";
    }
    typedef T type;
};

template <class T>
struct Mul {
    T operator()(T v1, T v2) const
    {
        return v1 * v2;
    }
    static std::string description()
    {
        return "*";
    }
    typedef T type;
};

// Unary operator
template <class T>
struct Pow {
    T operator()(T v) const
    {
        return v * v;
    }
    static std::string description()
    {
        return "^";
    }
    typedef T type;
};

// Finds a common type for T1 and T2 according to C++ conversion/promotion in arithmetic (float + int => float, etc)
template <class T1, class T2, bool T1_is_int = std::numeric_limits<T1>::is_integer || std::is_same_v<T1, null>,
          bool T2_is_int = std::numeric_limits<T2>::is_integer || std::is_same_v<T2, null>,
          bool T1_is_widest = (sizeof(T1) > sizeof(T2) || std::is_same_v<T2, null>)>
struct Common;
template <class T1, class T2, bool b>
struct Common<T1, T2, b, b, true> {
    typedef T1 type;
};
template <class T1, class T2, bool b>
struct Common<T1, T2, b, b, false> {
    typedef T2 type;
};
template <class T1, class T2, bool b>
struct Common<T1, T2, false, true, b> {
    typedef T1 type;
};
template <class T1, class T2, bool b>
struct Common<T1, T2, true, false, b> {
    typedef T2 type;
};

template <typename Operator>
struct OperatorOptionalAdapter {
    util::Optional<typename Operator::type> operator()(const Mixed& left, const Mixed& right)
    {
        if (left.is_null() || right.is_null())
            return util::none;
        return Operator()(left.template export_to_type<typename Operator::type>(),
                          right.template export_to_type<typename Operator::type>());
    }

    util::Optional<typename Operator::type> operator()(const Mixed& arg)
    {
        if (arg.is_null())
            return util::none;
        return Operator()(arg.template export_to_type<typename Operator::type>());
    }
};

class ValueBase {
public:
    using ValueType = QueryValue;

    static const size_t chunk_size = 8;
    bool m_from_link_list = false;

    ValueBase() = default;
    ValueBase(const ValueType& init_val)
    {
        m_first[0] = init_val;
    }
    ~ValueBase()
    {
        dealloc();
    }
    ValueBase(const ValueBase& other)
    {
        *this = other;
    }

    ValueBase& operator=(const ValueBase& other)
    {
        m_from_link_list = other.m_from_link_list;
        set(other.begin(), other.end());
        return *this;
    }

    size_t size() const
    {
        return m_size;
    }

    void init(bool from_link_list, size_t nb_values)
    {
        m_from_link_list = from_link_list;
        resize(nb_values);
    }

    void init_for_links(bool only_unary_links, size_t size)
    {
        if (only_unary_links) {
            REALM_ASSERT(size <= 1);
            init(false, 1);
            set_null(0);
        }
        else {
            init(true, size);
        }
    }

    void set_null(size_t ndx)
    {
        m_first[ndx] = ValueType();
    }

    template <class T>
    void set(size_t ndx, const T& val)
    {
        if constexpr (std::is_same<T, float>::value || std::is_same<T, double>::value) {
            m_first[ndx] = null::is_null_float(val) ? ValueType() : ValueType(val);
        }
        else {
            m_first[ndx] = ValueType(val);
        }
    }

    template <class T>
    void set(T b, T e)
    {
        size_t sz = e - b;
        resize(sz);
        size_t i = 0;
        for (auto from = b; from != e; ++from) {
            set(i, *from);
            i++;
        }
    }

    ValueType& operator[](size_t n)
    {
        return m_first[n];
    }

    const ValueType& operator[](size_t n) const
    {
        return m_first[n];
    }

    const ValueType& get(size_t n) const
    {
        return m_first[n];
    }

    ValueType* begin()
    {
        return m_first;
    }
    const ValueType* begin() const
    {
        return m_first;
    }

    ValueType* end()
    {
        return m_first + m_size;
    }
    const ValueType* end() const
    {
        return m_first + m_size;
    }
    template <class TOperator>
    REALM_FORCEINLINE void fun(const ValueBase& left, const ValueBase& right)
    {
        OperatorOptionalAdapter<TOperator> o;

        if (!left.m_from_link_list && !right.m_from_link_list) {
            // Operate on values one-by-one (one value is one row; no links)
            size_t min = std::min(left.size(), right.size());
            init(false, min);

            for (size_t i = 0; i < min; i++) {
                set(i, o(left[i], right[i]));
            }
        }
        else if (left.m_from_link_list && right.m_from_link_list) {
            // FIXME: Many-to-many links not supported yet. Need to specify behaviour
            REALM_ASSERT_DEBUG(false);
        }
        else if (!left.m_from_link_list && right.m_from_link_list) {
            // Right values come from link. Left must come from single row.
            REALM_ASSERT_DEBUG(left.size() > 0);
            init(true, right.size());

            auto left_value = left[0];
            for (size_t i = 0; i < right.size(); i++) {
                set(i, o(left_value, right[i]));
            }
        }
        else if (left.m_from_link_list && !right.m_from_link_list) {
            // Same as above, but with left values coming from links
            REALM_ASSERT_DEBUG(right.size() > 0);
            init(true, left.size());

            auto right_value = right[0];
            for (size_t i = 0; i < left.size(); i++) {
                set(i, o(left[i], right_value));
            }
        }
    }

    template <class TOperator>
    REALM_FORCEINLINE void fun(const ValueBase& value)
    {
        init(value.m_from_link_list, value.size());

        OperatorOptionalAdapter<TOperator> o;
        for (size_t i = 0; i < value.size(); i++) {
            set(i, o(value[i]));
        }
    }

    // Given a TCond (==, !=, >, <, >=, <=) and two Value<T>, return index of first match
    template <class TCond>
    REALM_FORCEINLINE static size_t compare_const(const ValueType& left, ValueBase& right,
                                                  ExpressionComparisonType comparison)
    {
        TCond c;
        const size_t sz = right.size();
        if (!right.m_from_link_list) {
            REALM_ASSERT_DEBUG(comparison ==
                               ExpressionComparisonType::Any); // ALL/NONE not supported for non list types
            for (size_t m = 0; m < sz; m++) {
                if (c(left, right[m]))
                    return m;
            }
        }
        else {
            for (size_t m = 0; m < sz; m++) {
                bool match = c(left, right[m]);
                if (match) {
                    if (comparison == ExpressionComparisonType::Any) {
                        return 0;
                    }
                    if (comparison == ExpressionComparisonType::None) {
                        return not_found; // one matched
                    }
                }
                else {
                    if (comparison == ExpressionComparisonType::All) {
                        return not_found;
                    }
                }
            }
            if (comparison == ExpressionComparisonType::None || comparison == ExpressionComparisonType::All) {
                return 0; // either none or all
            }
        }
        return not_found;
    }

    template <class TCond>
    REALM_FORCEINLINE static size_t compare(const ValueBase& left, const ValueBase& right,
                                            ExpressionComparisonType left_cmp_type,
                                            ExpressionComparisonType right_cmp_type)
    {
        TCond c;

        if (!left.m_from_link_list && !right.m_from_link_list) {
            REALM_ASSERT_DEBUG(left_cmp_type ==
                               ExpressionComparisonType::Any); // ALL/NONE not supported for non list types
            REALM_ASSERT_DEBUG(right_cmp_type ==
                               ExpressionComparisonType::Any); // ALL/NONE not supported for non list types
            // Compare values one-by-one (one value is one row; no link lists)
            size_t min = minimum(left.size(), right.size());
            for (size_t m = 0; m < min; m++) {
                if (c(left[m], right[m]))
                    return m;
            }
        }
        else if (left.m_from_link_list && right.m_from_link_list) {
            // FIXME: Many-to-many links not supported yet. Need to specify behaviour
            // knowing the comparison types means we can potentially support things such as:
            // ALL list.int > list.[FIRST].int
            // ANY list.int > ALL list2.int
            // NONE list.int > ANY list2.int
            REALM_ASSERT_DEBUG(false);
        }
        else if (!left.m_from_link_list && right.m_from_link_list) {
            // Right values come from link list. Left must come from single row. Semantics: Match if at least 1
            // linked-to-value fulfills the condition
            REALM_ASSERT_DEBUG(left.size() > 0);
            const size_t num_right_values = right.size();
            ValueType left_val = left[0];
            for (size_t r = 0; r < num_right_values; r++) {
                bool match = c(left_val, right[r]);
                if (match) {
                    if (right_cmp_type == ExpressionComparisonType::Any) {
                        return 0;
                    }
                    if (right_cmp_type == ExpressionComparisonType::None) {
                        return not_found; // one matched
                    }
                }
                else {
                    if (right_cmp_type == ExpressionComparisonType::All) {
                        return not_found;
                    }
                }
            }
            if (right_cmp_type == ExpressionComparisonType::None || right_cmp_type == ExpressionComparisonType::All) {
                return 0; // either none or all
            }
        }
        else if (left.m_from_link_list && !right.m_from_link_list) {
            // Same as above, but with left values coming from link list.
            REALM_ASSERT_DEBUG(right.size() > 0);
            const size_t num_left_values = left.size();
            ValueType right_val = right[0];
            for (size_t l = 0; l < num_left_values; l++) {
                bool match = c(left[l], right_val);
                if (match) {
                    if (left_cmp_type == ExpressionComparisonType::Any) {
                        return 0;
                    }
                    if (left_cmp_type == ExpressionComparisonType::None) {
                        return not_found; // one matched
                    }
                }
                else {
                    if (left_cmp_type == ExpressionComparisonType::All) {
                        return not_found;
                    }
                }
            }
            if (left_cmp_type == ExpressionComparisonType::None || left_cmp_type == ExpressionComparisonType::All) {
                return 0; // either none or all
            }
        }

        return not_found; // no match
    }

private:
    // If true, all values in the class come from a link list of a single field in the parent table (m_table). If
    // false, then values come from successive rows of m_table (query operations are operated on in bulks for speed)
    static constexpr size_t prealloc = 8;

    QueryValue m_cache[prealloc];
    QueryValue* m_first = &m_cache[0];
    size_t m_size = 1;

    void resize(size_t size)
    {
        if (size == m_size)
            return;

        dealloc();
        m_size = size;
        if (m_size > 0) {
            if (m_size > prealloc)
                m_first = new QueryValue[m_size];
            else
                m_first = &m_cache[0];
        }
    }
    void dealloc()
    {
        if (m_first) {
            if (m_size > prealloc)
                delete[] m_first;
            m_first = nullptr;
        }
    }
    void fill(const QueryValue& val)
    {
        for (size_t i = 0; i < m_size; i++) {
            m_first[i] = val;
        }
    }
};

class Expression {
public:
    Expression() {}
    virtual ~Expression() {}

    virtual double init()
    {
        return 50.0; // Default dT
    }

    virtual size_t find_first(size_t start, size_t end) const = 0;
    virtual void set_base_table(ConstTableRef table) = 0;
    virtual void set_cluster(const Cluster*) = 0;
    virtual void collect_dependencies(std::vector<TableKey>&) const {}
    virtual ConstTableRef get_base_table() const = 0;
    virtual std::string description(util::serializer::SerialisationState& state) const = 0;

    virtual std::unique_ptr<Expression> clone() const = 0;
};

template <typename T, typename... Args>
std::unique_ptr<Expression> make_expression(Args&&... args)
{
    return std::unique_ptr<Expression>(new T(std::forward<Args>(args)...));
}

class Subexpr {
public:
    virtual ~Subexpr() {}

    virtual std::unique_ptr<Subexpr> clone() const = 0;

    // When the user constructs a query, it always "belongs" to one single base/parent table (regardless of
    // any links or not and regardless of any queries assembled with || or &&). When you do a Query::find(),
    // then Query::m_table is set to this table, and set_base_table() is called on all Columns and LinkMaps in
    // the query expression tree so that they can set/update their internals as required.
    //
    // During thread-handover of a Query, set_base_table() is also called to make objects point at the new table
    // instead of the old one from the old thread.
    virtual void set_base_table(ConstTableRef) {}

    virtual std::string description(util::serializer::SerialisationState& state) const = 0;

    virtual void set_cluster(const Cluster*) {}

    // Recursively fetch tables of columns in expression tree. Used when user first builds a stand-alone expression
    // and
    // binds it to a Query at a later time
    virtual ConstTableRef get_base_table() const
    {
        return nullptr;
    }

    virtual void collect_dependencies(std::vector<TableKey>&) const {}

    virtual bool has_constant_evaluation() const
    {
        return false;
    }

    virtual bool has_multiple_values() const
    {
        return false;
    }

    virtual bool has_search_index() const
    {
        return false;
    }

    virtual std::vector<ObjKey> find_all(Mixed) const
    {
        return {};
    }

    virtual DataType get_type() const = 0;

    virtual void evaluate(size_t index, ValueBase& destination) = 0;
    // This function supports SubColumnAggregate
    virtual void evaluate(ObjKey, ValueBase&)
    {
        REALM_ASSERT(false); // Unimplemented
    }

    virtual Mixed get_mixed()
    {
        return {};
    }

    virtual ExpressionComparisonType get_comparison_type() const
    {
        return ExpressionComparisonType::Any;
    }
};

template <typename T, typename... Args>
std::unique_ptr<Subexpr> make_subexpr(Args&&... args)
{
    return std::unique_ptr<Subexpr>(new T(std::forward<Args>(args)...));
}

template <class T>
class Columns;
template <class T>
class Value;
class ConstantStringValue;
template <class T>
class Subexpr2;
template <class oper, class TLeft = Subexpr, class TRight = Subexpr>
class Operator;
template <class oper, class TLeft = Subexpr>
class UnaryOperator;
template <class oper, class TLeft = Subexpr>
class SizeOperator;
template <class oper>
class TypeOfValueOperator;
template <class TCond>
class Compare;
template <bool has_links>
class UnaryLinkCompare;
class ColumnAccessorBase;


// Handle cases where left side is a constant (int, float, int64_t, double, StringData)
template <class Cond, class L, class R>
Query create(L left, const Subexpr2<R>& right)
{
    // Purpose of below code is to intercept the creation of a condition and test if it's supported by the old
    // query_engine.hpp which is faster. If it's supported, create a query_engine.hpp node, otherwise create a
    // query_expression.hpp node.
    //
    // This method intercepts only Value <cond> Subexpr2. Interception of Subexpr2 <cond> Subexpr is elsewhere.

    constexpr const bool supported_by_old_query_engine =
        (std::numeric_limits<L>::is_integer && std::numeric_limits<R>::is_integer) || std::is_same_v<R, Mixed> ||
        (std::is_same_v<L, R> &&
         realm::is_any_v<L, double, float, Timestamp, StringData, BinaryData, ObjectId, UUID>);

    if constexpr (REALM_OLDQUERY_FALLBACK && supported_by_old_query_engine) {
        const Columns<R>* column = dynamic_cast<const Columns<R>*>(&right);
        // TODO: recognize size operator expressions
        // auto size_operator = dynamic_cast<const SizeOperator<Size<StringData>, Subexpr>*>(&right);

        if (column && !column->links_exist()) {
            ConstTableRef t = column->get_base_table();
            Query q(t);

            if constexpr (std::is_same_v<Cond, Less>)
                q.greater(column->column_key(), static_cast<R>(left));
            else if constexpr (std::is_same_v<Cond, Greater>)
                q.less(column->column_key(), static_cast<R>(left));
            else if constexpr (std::is_same_v<Cond, Equal>)
                q.equal(column->column_key(), static_cast<R>(left));
            else if constexpr (std::is_same_v<Cond, NotEqual>)
                q.not_equal(column->column_key(), static_cast<R>(left));
            else if constexpr (std::is_same_v<Cond, LessEqual>)
                q.greater_equal(column->column_key(), static_cast<R>(left));
            else if constexpr (std::is_same_v<Cond, GreaterEqual>)
                q.less_equal(column->column_key(), static_cast<R>(left));
            else if constexpr (std::is_same_v<Cond, EqualIns>)
                q.equal(column->column_key(), left, false);
            else if constexpr (std::is_same_v<Cond, NotEqualIns>)
                q.not_equal(column->column_key(), left, false);
            else if constexpr (std::is_same_v<Cond, BeginsWith>)
                q.begins_with(column->column_key(), left);
            else if constexpr (std::is_same_v<Cond, BeginsWithIns>)
                q.begins_with(column->column_key(), left, false);
            else if constexpr (std::is_same_v<Cond, EndsWith>)
                q.ends_with(column->column_key(), left);
            else if constexpr (std::is_same_v<Cond, EndsWithIns>)
                q.ends_with(column->column_key(), left, false);
            else if constexpr (std::is_same_v<Cond, Contains>)
                q.contains(column->column_key(), left);
            else if constexpr (std::is_same_v<Cond, ContainsIns>)
                q.contains(column->column_key(), left, false);
            else if constexpr (std::is_same_v<Cond, Like>)
                q.like(column->column_key(), left);
            else if constexpr (std::is_same_v<Cond, LikeIns>)
                q.like(column->column_key(), left, false);
            else {
                // query_engine.hpp does not support this Cond. Please either add support for it in query_engine.hpp
                // or fallback to using use 'return new Compare<>' instead.
                REALM_ASSERT(false);
            }
            return q;
        }
    }

    // Return query_expression.hpp node
    using ValueType = typename std::conditional_t<std::is_same_v<L, StringData>, ConstantStringValue, Value<L>>;
    return make_expression<Compare<Cond>>(make_subexpr<ValueType>(left), right.clone());
}

// All overloads where left-hand-side is Subexpr2<L>:
//
// left-hand-side       operator                              right-hand-side
// Subexpr2<L>          +, -, *, /, <, >, ==, !=, <=, >=      R, Subexpr2<R>
//
// For L = R = {int, int64_t, float, double, StringData, Timestamp}:
template <class L, class R>
class Overloads {
    typedef typename Common<L, R>::type CommonType;

    std::unique_ptr<Subexpr> clone_subexpr() const
    {
        return static_cast<const Subexpr2<L>&>(*this).clone();
    }

public:
    // Arithmetic, right side constant
    Operator<Plus<CommonType>> operator+(R right) const
    {
        return {clone_subexpr(), make_subexpr<Value<R>>(right)};
    }
    Operator<Minus<CommonType>> operator-(R right) const
    {
        return {clone_subexpr(), make_subexpr<Value<R>>(right)};
    }
    Operator<Mul<CommonType>> operator*(R right) const
    {
        return {clone_subexpr(), make_subexpr<Value<R>>(right)};
    }
    Operator<Div<CommonType>> operator/(R right) const
    {
        return {clone_subexpr(), make_subexpr<Value<R>>(right)};
    }

    // Arithmetic, right side subexpression
    Operator<Plus<CommonType>> operator+(const Subexpr2<R>& right) const
    {
        return {clone_subexpr(), right.clone()};
    }
    Operator<Minus<CommonType>> operator-(const Subexpr2<R>& right) const
    {
        return {clone_subexpr(), right.clone()};
    }
    Operator<Mul<CommonType>> operator*(const Subexpr2<R>& right) const
    {
        return {clone_subexpr(), right.clone()};
    }
    Operator<Div<CommonType>> operator/(const Subexpr2<R>& right) const
    {
        return {clone_subexpr(), right.clone()};
    }

    // Compare, right side constant
    Query operator>(R right)
    {
        return create<Less>(right, static_cast<Subexpr2<L>&>(*this));
    }
    Query operator<(R right)
    {
        return create<Greater>(right, static_cast<Subexpr2<L>&>(*this));
    }
    Query operator>=(R right)
    {
        return create<LessEqual>(right, static_cast<Subexpr2<L>&>(*this));
    }
    Query operator<=(R right)
    {
        return create<GreaterEqual>(right, static_cast<Subexpr2<L>&>(*this));
    }
    Query operator==(R right)
    {
        return create<Equal>(right, static_cast<Subexpr2<L>&>(*this));
    }
    Query operator!=(R right)
    {
        return create<NotEqual>(right, static_cast<Subexpr2<L>&>(*this));
    }

    // Purpose of this method is to intercept the creation of a condition and test if it's supported by the old
    // query_engine.hpp which is faster. If it's supported, create a query_engine.hpp node, otherwise create a
    // query_expression.hpp node.
    //
    // This method intercepts Subexpr2 <cond> Subexpr2 only. Value <cond> Subexpr2 is intercepted elsewhere.
    template <class Cond>
    Query create2(const Subexpr2<R>& right)
    {
#ifdef REALM_OLDQUERY_FALLBACK // if not defined, never fallback query_engine; always use query_expression
        // Test if expressions are of type Columns. Other possibilities are Value and Operator.
        const Columns<L>* left_col = dynamic_cast<const Columns<L>*>(static_cast<Subexpr2<L>*>(this));
        const Columns<R>* right_col = dynamic_cast<const Columns<R>*>(&right);

        // query_engine supports 'T-column <op> <T-column>' for T = {int64_t, float, double}, op = {<, >, ==, !=, <=,
        // >=},
        // but only if both columns are non-nullable, and aren't in linked tables.
        if (left_col && right_col) {
            ConstTableRef t = left_col->get_base_table();
            ConstTableRef t_right = right_col->get_base_table();
            REALM_ASSERT_DEBUG(t);
            REALM_ASSERT_DEBUG(t_right);
            // we only support multi column comparisons if they stem from the same table
            if (t->get_key() != t_right->get_key()) {
                throw std::runtime_error(util::format(
                    "Comparison between two properties must be linked with a relationship or exist on the same "
                    "Table (%1 and %2)",
                    t->get_name(), t_right->get_name()));
            }
            if (!left_col->links_exist() && !right_col->links_exist()) {
                if constexpr (std::is_same_v<Cond, Less>)
                    return Query(t).less(left_col->column_key(), right_col->column_key());
                if constexpr (std::is_same_v<Cond, Greater>)
                    return Query(t).greater(left_col->column_key(), right_col->column_key());
                if constexpr (std::is_same_v<Cond, Equal>)
                    return Query(t).equal(left_col->column_key(), right_col->column_key());
                if constexpr (std::is_same_v<Cond, NotEqual>)
                    return Query(t).not_equal(left_col->column_key(), right_col->column_key());
                if constexpr (std::is_same_v<Cond, LessEqual>)
                    return Query(t).less_equal(left_col->column_key(), right_col->column_key());
                if constexpr (std::is_same_v<Cond, GreaterEqual>)
                    return Query(t).greater_equal(left_col->column_key(), right_col->column_key());
            }
        }
#endif
        // Return query_expression.hpp node
        return make_expression<Compare<Cond>>(clone_subexpr(), right.clone());
    }

    // Compare, right side subexpression
    Query operator==(const Subexpr2<R>& right)
    {
        return create2<Equal>(right);
    }
    Query operator!=(const Subexpr2<R>& right)
    {
        return create2<NotEqual>(right);
    }
    Query operator>(const Subexpr2<R>& right)
    {
        return create2<Greater>(right);
    }
    Query operator<(const Subexpr2<R>& right)
    {
        return create2<Less>(right);
    }
    Query operator>=(const Subexpr2<R>& right)
    {
        return create2<GreaterEqual>(right);
    }
    Query operator<=(const Subexpr2<R>& right)
    {
        return create2<LessEqual>(right);
    }
};

// With this wrapper class we can define just 20 overloads inside Overloads<L, R> instead of 5 * 20 = 100. Todo: We
// can
// consider if it's simpler/better to remove this class completely and just list all 100 overloads manually anyway.
template <class T>
class Subexpr2 : public Subexpr,
                 public Overloads<T, const char*>,
                 public Overloads<T, int>,
                 public Overloads<T, float>,
                 public Overloads<T, double>,
                 public Overloads<T, int64_t>,
                 public Overloads<T, StringData>,
                 public Overloads<T, bool>,
                 public Overloads<T, Timestamp>,
                 public Overloads<T, ObjectId>,
                 public Overloads<T, Decimal128>,
                 public Overloads<T, UUID>,
                 public Overloads<T, Mixed>,
                 public Overloads<T, null> {
public:
    virtual ~Subexpr2() {}

    DataType get_type() const final
    {
        return ColumnTypeTraits<T>::id;
    }

#define RLM_U2(t, o) using Overloads<T, t>::operator o;
#define RLM_U(o)                                                                                                     \
    RLM_U2(int, o)                                                                                                   \
    RLM_U2(float, o)                                                                                                 \
    RLM_U2(double, o)                                                                                                \
    RLM_U2(int64_t, o)                                                                                               \
    RLM_U2(StringData, o)                                                                                            \
    RLM_U2(bool, o)                                                                                                  \
    RLM_U2(Timestamp, o)                                                                                             \
    RLM_U2(ObjectId, o)                                                                                              \
    RLM_U2(Decimal128, o)                                                                                            \
    RLM_U2(UUID, o)                                                                                                  \
    RLM_U2(Mixed, o)                                                                                                 \
    RLM_U2(null, o)
    RLM_U(+) RLM_U(-) RLM_U(*) RLM_U(/) RLM_U(>) RLM_U(<) RLM_U(==) RLM_U(!=) RLM_U(>=) RLM_U(<=)
};

// Subexpr2<Link> only provides equality comparisons. Their implementations can be found later in this file.
template <>
class Subexpr2<Link> : public Subexpr {
public:
    DataType get_type() const
    {
        return type_Link;
    }
};

template <>
class Subexpr2<StringData> : public Subexpr, public Overloads<StringData, StringData> {
public:
    Query equal(StringData sd, bool case_sensitive = true);
    Query equal(const Subexpr2<StringData>& col, bool case_sensitive = true);
    Query not_equal(StringData sd, bool case_sensitive = true);
    Query not_equal(const Subexpr2<StringData>& col, bool case_sensitive = true);
    Query begins_with(StringData sd, bool case_sensitive = true);
    Query begins_with(const Subexpr2<StringData>& col, bool case_sensitive = true);
    Query ends_with(StringData sd, bool case_sensitive = true);
    Query ends_with(const Subexpr2<StringData>& col, bool case_sensitive = true);
    Query contains(StringData sd, bool case_sensitive = true);
    Query contains(const Subexpr2<StringData>& col, bool case_sensitive = true);
    Query like(StringData sd, bool case_sensitive = true);
    Query like(const Subexpr2<StringData>& col, bool case_sensitive = true);
    DataType get_type() const final
    {
        return type_String;
    }
};

template <>
class Subexpr2<BinaryData> : public Subexpr, public Overloads<BinaryData, BinaryData> {
public:
    Query equal(BinaryData sd, bool case_sensitive = true);
    Query equal(const Subexpr2<BinaryData>& col, bool case_sensitive = true);
    Query not_equal(BinaryData sd, bool case_sensitive = true);
    Query not_equal(const Subexpr2<BinaryData>& col, bool case_sensitive = true);
    Query begins_with(BinaryData sd, bool case_sensitive = true);
    Query begins_with(const Subexpr2<BinaryData>& col, bool case_sensitive = true);
    Query ends_with(BinaryData sd, bool case_sensitive = true);
    Query ends_with(const Subexpr2<BinaryData>& col, bool case_sensitive = true);
    Query contains(BinaryData sd, bool case_sensitive = true);
    Query contains(const Subexpr2<BinaryData>& col, bool case_sensitive = true);
    Query like(BinaryData sd, bool case_sensitive = true);
    Query like(const Subexpr2<BinaryData>& col, bool case_sensitive = true);
    DataType get_type() const final
    {
        return type_Binary;
    }
};

template <>
class Subexpr2<Mixed> : public Subexpr,
                        public Overloads<Mixed, Mixed>,
                        public Overloads<Mixed, const char*>,
                        public Overloads<Mixed, int>,
                        public Overloads<Mixed, float>,
                        public Overloads<Mixed, double>,
                        public Overloads<Mixed, int64_t>,
                        public Overloads<Mixed, StringData>,
                        public Overloads<Mixed, bool>,
                        public Overloads<Mixed, Timestamp>,
                        public Overloads<Mixed, ObjectId>,
                        public Overloads<Mixed, Decimal128>,
                        public Overloads<Mixed, UUID>,
                        public Overloads<Mixed, null> {
public:
    Query equal(Mixed sd, bool case_sensitive = true);
    Query equal(const Subexpr2<Mixed>& col, bool case_sensitive = true);
    Query not_equal(Mixed sd, bool case_sensitive = true);
    Query not_equal(const Subexpr2<Mixed>& col, bool case_sensitive = true);
    Query begins_with(Mixed sd, bool case_sensitive = true);
    Query begins_with(const Subexpr2<Mixed>& col, bool case_sensitive = true);
    Query ends_with(Mixed sd, bool case_sensitive = true);
    Query ends_with(const Subexpr2<Mixed>& col, bool case_sensitive = true);
    Query contains(Mixed sd, bool case_sensitive = true);
    Query contains(const Subexpr2<Mixed>& col, bool case_sensitive = true);
    Query like(Mixed sd, bool case_sensitive = true);
    Query like(const Subexpr2<Mixed>& col, bool case_sensitive = true);
    DataType get_type() const final
    {
        return type_Mixed;
    }

    using T = Mixed; // used inside the following macros for operator overloads
    RLM_U(+) RLM_U(-) RLM_U(*) RLM_U(/) RLM_U(>) RLM_U(<) RLM_U(==) RLM_U(!=) RLM_U(>=) RLM_U(<=)
};

template <>
class Subexpr2<TypeOfValue> : public Subexpr, public Overloads<TypeOfValue, TypeOfValue> {
public:
    Query equal(TypeOfValue v);
    Query equal(const TypeOfValueOperator<Mixed>& col);
    Query not_equal(TypeOfValue v);
    Query not_equal(const TypeOfValueOperator<Mixed>& col);
    DataType get_type() const final
    {
        return type_TypeOfValue;
    }
};

struct TrueExpression : Expression {
    size_t find_first(size_t start, size_t end) const override
    {
        REALM_ASSERT(start <= end);
        if (start != end)
            return start;

        return realm::not_found;
    }
    void set_base_table(ConstTableRef) override {}
    void set_cluster(const Cluster*) override {}
    ConstTableRef get_base_table() const override
    {
        return nullptr;
    }
    std::string description(util::serializer::SerialisationState&) const override
    {
        return "TRUEPREDICATE";
    }
    std::unique_ptr<Expression> clone() const override
    {
        return std::unique_ptr<Expression>(new TrueExpression(*this));
    }
};


struct FalseExpression : Expression {
    size_t find_first(size_t, size_t) const override
    {
        return realm::not_found;
    }
    void set_base_table(ConstTableRef) override {}
    void set_cluster(const Cluster*) override {}
    std::string description(util::serializer::SerialisationState&) const override
    {
        return "FALSEPREDICATE";
    }
    ConstTableRef get_base_table() const override
    {
        return nullptr;
    }
    std::unique_ptr<Expression> clone() const override
    {
        return std::unique_ptr<Expression>(new FalseExpression(*this));
    }
};


// Stores N values of type T. Can also exchange data with other ValueBase of different types
template <class T>
class Value : public ValueBase, public Subexpr2<T> {
public:
    Value() = default;

    Value(T init)
        : ValueBase(QueryValue(init))
    {
    }

    std::string description(util::serializer::SerialisationState&) const override
    {
        if (ValueBase::m_from_link_list) {
            return util::serializer::print_value(util::to_string(ValueBase::size()) +
                                                 (ValueBase::size() == 1 ? " value" : " values"));
        }
        if (size() > 0) {
            auto val = get(0);
            if (val.is_null())
                return "NULL";
            else {
                if constexpr (std::is_same_v<T, TypeOfValue>) {
                    return util::serializer::print_value(val.get_type_of_value());
                }
                else {
                    return util::serializer::print_value(val.template get<T>());
                }
            }
        }
        return "";
    }

    bool has_constant_evaluation() const override
    {
        return true;
    }

    Mixed get_mixed() override
    {
        return get(0);
    }

    void evaluate(size_t, ValueBase& destination) override
    {
        destination = *this;
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<Value<T>>(*this);
    }
};

class ConstantStringValue : public Value<StringData> {
public:
    ConstantStringValue(const StringData& string)
        : Value()
        , m_string(string.is_null() ? util::none : util::make_optional(std::string(string)))
    {
        if (m_string)
            set(0, *m_string);
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return std::unique_ptr<Subexpr>(new ConstantStringValue(*this));
    }

private:
    ConstantStringValue(const ConstantStringValue& other)
        : Value()
        , m_string(other.m_string)
    {
        if (m_string)
            set(0, *m_string);
    }

    util::Optional<std::string> m_string;
};

class ConstantBinaryValue : public Value<BinaryData> {
public:
    ConstantBinaryValue(const BinaryData& bin)
        : Value()
        , m_buffer(bin)
    {
        if (m_buffer.data())
            set(0, BinaryData(m_buffer.data(), m_buffer.size()));
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return std::unique_ptr<Subexpr>(new ConstantBinaryValue(*this));
    }

private:
    ConstantBinaryValue(const ConstantBinaryValue& other)
        : Value()
        , m_buffer(other.m_buffer)
    {
        if (m_buffer.data())
            set(0, BinaryData(m_buffer.data(), m_buffer.size()));
    }

    OwnedBinaryData m_buffer;
};

// All overloads where left-hand-side is L:
//
// left-hand-side       operator                              right-hand-side
// L                    +, -, *, /, <, >, ==, !=, <=, >=      Subexpr2<R>
//
// For L = R = {int, int64_t, float, double, Timestamp, ObjectId, Decimal128}:
// Compare numeric values
template <class R>
Query operator>(double left, const Subexpr2<R>& right)
{
    return create<Greater>(left, right);
}
template <class R>
Query operator>(float left, const Subexpr2<R>& right)
{
    return create<Greater>(left, right);
}
template <class R>
Query operator>(int left, const Subexpr2<R>& right)
{
    return create<Greater>(left, right);
}
template <class R>
Query operator>(int64_t left, const Subexpr2<R>& right)
{
    return create<Greater>(left, right);
}
template <class R>
Query operator>(Timestamp left, const Subexpr2<R>& right)
{
    return create<Greater>(left, right);
}
template <class R>
Query operator>(ObjectId left, const Subexpr2<R>& right)
{
    return create<Greater>(left, right);
}
template <class R>
Query operator>(Decimal128 left, const Subexpr2<R>& right)
{
    return create<Greater>(left, right);
}

template <class R>
Query operator<(double left, const Subexpr2<R>& right)
{
    return create<Less>(left, right);
}
template <class R>
Query operator<(float left, const Subexpr2<R>& right)
{
    return create<Less>(left, right);
}
template <class R>
Query operator<(int left, const Subexpr2<R>& right)
{
    return create<Less>(left, right);
}
template <class R>
Query operator<(int64_t left, const Subexpr2<R>& right)
{
    return create<Less>(left, right);
}
template <class R>
Query operator<(Timestamp left, const Subexpr2<R>& right)
{
    return create<Less>(left, right);
}
template <class R>
Query operator<(ObjectId left, const Subexpr2<R>& right)
{
    return create<Less>(left, right);
}
template <class R>
Query operator<(Decimal128 left, const Subexpr2<R>& right)
{
    return create<Less>(left, right);
}

template <class R>
Query operator==(double left, const Subexpr2<R>& right)
{
    return create<Equal>(left, right);
}
template <class R>
Query operator==(float left, const Subexpr2<R>& right)
{
    return create<Equal>(left, right);
}
template <class R>
Query operator==(int left, const Subexpr2<R>& right)
{
    return create<Equal>(left, right);
}
template <class R>
Query operator==(int64_t left, const Subexpr2<R>& right)
{
    return create<Equal>(left, right);
}
template <class R>
Query operator==(Timestamp left, const Subexpr2<R>& right)
{
    return create<Equal>(left, right);
}
template <class R>
Query operator==(ObjectId left, const Subexpr2<R>& right)
{
    return create<Equal>(left, right);
}
template <class R>
Query operator==(Decimal128 left, const Subexpr2<R>& right)
{
    return create<Equal>(left, right);
}
template <class R>
Query operator==(bool left, const Subexpr2<R>& right)
{
    return create<Equal>(left, right);
}
template <class R>
Query operator==(UUID left, const Subexpr2<R>& right)
{
    return create<Equal>(left, right);
}


template <class R>
Query operator>=(double left, const Subexpr2<R>& right)
{
    return create<GreaterEqual>(left, right);
}
template <class R>
Query operator>=(float left, const Subexpr2<R>& right)
{
    return create<GreaterEqual>(left, right);
}
template <class R>
Query operator>=(int left, const Subexpr2<R>& right)
{
    return create<GreaterEqual>(left, right);
}
template <class R>
Query operator>=(int64_t left, const Subexpr2<R>& right)
{
    return create<GreaterEqual>(left, right);
}
template <class R>
Query operator>=(Timestamp left, const Subexpr2<R>& right)
{
    return create<GreaterEqual>(left, right);
}
template <class R>
Query operator>=(ObjectId left, const Subexpr2<R>& right)
{
    return create<GreaterEqual>(left, right);
}
template <class R>
Query operator>=(Decimal128 left, const Subexpr2<R>& right)
{
    return create<GreaterEqual>(left, right);
}

template <class R>
Query operator<=(double left, const Subexpr2<R>& right)
{
    return create<LessEqual>(left, right);
}
template <class R>
Query operator<=(float left, const Subexpr2<R>& right)
{
    return create<LessEqual>(left, right);
}
template <class R>
Query operator<=(int left, const Subexpr2<R>& right)
{
    return create<LessEqual>(left, right);
}
template <class R>
Query operator<=(int64_t left, const Subexpr2<R>& right)
{
    return create<LessEqual>(left, right);
}
template <class R>
Query operator<=(Timestamp left, const Subexpr2<R>& right)
{
    return create<LessEqual>(left, right);
}
template <class R>
Query operator<=(ObjectId left, const Subexpr2<R>& right)
{
    return create<LessEqual>(left, right);
}
template <class R>
Query operator<=(Decimal128 left, const Subexpr2<R>& right)
{
    return create<LessEqual>(left, right);
}

template <class R>
Query operator!=(double left, const Subexpr2<R>& right)
{
    return create<NotEqual>(left, right);
}
template <class R>
Query operator!=(float left, const Subexpr2<R>& right)
{
    return create<NotEqual>(left, right);
}
template <class R>
Query operator!=(int left, const Subexpr2<R>& right)
{
    return create<NotEqual>(left, right);
}
template <class R>
Query operator!=(int64_t left, const Subexpr2<R>& right)
{
    return create<NotEqual>(left, right);
}
template <class R>
Query operator!=(Timestamp left, const Subexpr2<R>& right)
{
    return create<NotEqual>(left, right);
}
template <class R>
Query operator!=(ObjectId left, const Subexpr2<R>& right)
{
    return create<NotEqual>(left, right);
}
template <class R>
Query operator!=(Decimal128 left, const Subexpr2<R>& right)
{
    return create<NotEqual>(left, right);
}
template <class R>
Query operator!=(bool left, const Subexpr2<R>& right)
{
    return create<NotEqual>(left, right);
}
template <class R>
Query operator!=(UUID left, const Subexpr2<R>& right)
{
    return create<NotEqual>(left, right);
}

// Arithmetic
template <class R>
Operator<Plus<typename Common<R, double>::type>> operator+(double left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<double>>(left), right.clone()};
}
template <class R>
Operator<Plus<typename Common<R, float>::type>> operator+(float left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<float>>(left), right.clone()};
}
template <class R>
Operator<Plus<typename Common<R, int>::type>> operator+(int left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<int>>(left), right.clone()};
}
template <class R>
Operator<Plus<typename Common<R, int64_t>::type>> operator+(int64_t left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<int64_t>>(left), right.clone()};
}
template <class R>
Operator<Minus<typename Common<R, double>::type>> operator-(double left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<double>>(left), right.clone()};
}
template <class R>
Operator<Minus<typename Common<R, float>::type>> operator-(float left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<float>>(left), right.clone()};
}
template <class R>
Operator<Minus<typename Common<R, int>::type>> operator-(int left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<int>>(left), right.clone()};
}
template <class R>
Operator<Minus<typename Common<R, int64_t>::type>> operator-(int64_t left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<int64_t>>(left), right.clone()};
}
template <class R>
Operator<Mul<typename Common<R, double>::type>> operator*(double left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<double>>(left), right.clone()};
}
template <class R>
Operator<Mul<typename Common<R, float>::type>> operator*(float left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<float>>(left), right.clone()};
}
template <class R>
Operator<Mul<typename Common<R, int>::type>> operator*(int left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<int>>(left), right.clone()};
}
template <class R>
Operator<Mul<typename Common<R, int64_t>::type>> operator*(int64_t left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<int64_t>>(left), right.clone()};
}
template <class R>
Operator<Div<typename Common<R, double>::type>> operator/(double left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<double>>(left), right.clone()};
}
template <class R>
Operator<Div<typename Common<R, float>::type>> operator/(float left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<float>>(left), right.clone()};
}
template <class R>
Operator<Div<typename Common<R, int>::type>> operator/(int left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<int>>(left), right.clone()};
}
template <class R>
Operator<Div<typename Common<R, int64_t>::type>> operator/(int64_t left, const Subexpr2<R>& right)
{
    return {make_subexpr<Value<int64_t>>(left), right.clone()};
}

// Unary operators
template <class T>
UnaryOperator<Pow<T>> power(const Subexpr2<T>& left)
{
    return {left.clone()};
}

// Classes used for LinkMap (see below).
struct LinkMapFunction {
    // Your consume() method is given key within the linked-to table as argument, and you must return whether or
    // not you want the LinkMapFunction to exit (return false) or continue (return true) harvesting the link tree
    // for the current main table object (it will be a link tree if you have multiple type_LinkList columns
    // in a link()->link() query.
    virtual bool consume(ObjKey) = 0;
};

struct FindNullLinks : public LinkMapFunction {
    bool consume(ObjKey) override
    {
        m_has_link = true;
        return false; // we've found a key, so this can't be a null-link, so exit link harvesting
    }

    bool m_has_link = false;
};

struct MakeLinkVector : public LinkMapFunction {
    MakeLinkVector(std::vector<ObjKey>& result)
        : m_links(result)
    {
    }

    bool consume(ObjKey key) override
    {
        m_links.push_back(key);
        return true; // continue evaluation
    }
    std::vector<ObjKey>& m_links;
};

struct UnaryLinkResult : public LinkMapFunction {
    bool consume(ObjKey key) override
    {
        m_result = key;
        return false; // exit search, only one result ever expected
    }
    ObjKey m_result;
};

struct CountLinks : public LinkMapFunction {
    bool consume(ObjKey) override
    {
        m_link_count++;
        return true;
    }

    size_t result() const
    {
        return m_link_count;
    }

    size_t m_link_count = 0;
};

struct CountBacklinks : public LinkMapFunction {
    CountBacklinks(ConstTableRef t)
        : m_table(t)
    {
    }

    bool consume(ObjKey key) override
    {
        m_link_count += m_table.unchecked_ptr()->get_object(key).get_backlink_count();
        return true;
    }

    size_t result() const
    {
        return m_link_count;
    }

    ConstTableRef m_table;
    size_t m_link_count = 0;
};


/*
The LinkMap and LinkMapFunction classes are used for query conditions on links themselves (contrary to conditions on
the value payload they point at).

MapLink::map_links() takes a row index of the link array as argument and follows any link chain stated in the query
(through the link()->link() methods) until the final payload table is reached, and then applies LinkMapFunction on
the linked-to key(s).

If all link columns are type_Link, then LinkMapFunction is only invoked for a single key. If one or more
columns are type_LinkList, then it may result in multiple keys.

The reason we use this map pattern is that we can exit the link-tree-traversal as early as possible, e.g. when we've
found the first link that points to key '5'. Other solutions could be a std::vector<ColKey> harvest_all_links(), or an
iterator pattern. First solution can't exit, second solution requires internal state.
*/
class LinkMap {
public:
    LinkMap() = default;
    LinkMap(ConstTableRef table, std::vector<ColKey> columns)
        : m_link_column_keys(std::move(columns))
    {
        set_base_table(table);
    }

    LinkMap(LinkMap const& other)
    {
        m_link_column_keys = other.m_link_column_keys;
        m_tables = other.m_tables;
        m_link_types = other.m_link_types;
        m_only_unary_links = other.m_only_unary_links;
    }

    size_t get_nb_hops() const
    {
        return m_link_column_keys.size();
    }

    bool has_links() const
    {
        return m_link_column_keys.size() > 0;
    }

    ColKey get_first_column_key() const
    {
        REALM_ASSERT(has_links());
        return m_link_column_keys[0];
    }

    void set_base_table(ConstTableRef table);

    void set_cluster(const Cluster* cluster)
    {
        Allocator& alloc = get_base_table()->get_alloc();
        m_array_ptr = nullptr;
        switch (m_link_types[0]) {
            case col_type_Link:
                m_array_ptr = LeafPtr(new (&m_storage.m_list) ArrayKey(alloc));
                break;
            case col_type_LinkList:
                m_array_ptr = LeafPtr(new (&m_storage.m_linklist) ArrayList(alloc));
                break;
            case col_type_BackLink:
                m_array_ptr = LeafPtr(new (&m_storage.m_backlink) ArrayBacklink(alloc));
                break;
            default:
                break;
        }
        // m_tables[0]->report_invalid_key(m_link_column_keys[0]);
        cluster->init_leaf(m_link_column_keys[0], m_array_ptr.get());
        m_leaf_ptr = m_array_ptr.get();
    }

    void collect_dependencies(std::vector<TableKey>& tables) const;

    virtual std::string description(util::serializer::SerialisationState& state) const;

    ObjKey get_unary_link_or_not_found(size_t index) const
    {
        REALM_ASSERT(m_only_unary_links);
        UnaryLinkResult res;
        map_links(index, res);
        return res.m_result;
    }

    std::vector<ObjKey> get_links(size_t index) const
    {
        std::vector<ObjKey> res;
        get_links(index, res);
        return res;
    }

    std::vector<ObjKey> get_origin_ndxs(ObjKey key, size_t column = 0) const;

    size_t count_links(size_t row) const
    {
        CountLinks counter;
        map_links(row, counter);
        return counter.result();
    }

    size_t count_all_backlinks(size_t row) const
    {
        CountBacklinks counter(get_target_table());
        map_links(row, counter);
        return counter.result();
    }

    void map_links(size_t row, LinkMapFunction& lm) const
    {
        map_links(0, row, lm);
    }

    bool only_unary_links() const
    {
        return m_only_unary_links;
    }

    ConstTableRef get_base_table() const
    {
        return m_tables.empty() ? nullptr : m_tables[0];
    }

    ConstTableRef get_target_table() const
    {
        REALM_ASSERT(!m_tables.empty());
        return m_tables.back();
    }

    bool links_exist() const
    {
        return !m_link_column_keys.empty();
    }

private:
    void map_links(size_t column, ObjKey key, LinkMapFunction& lm) const;
    void map_links(size_t column, size_t row, LinkMapFunction& lm) const;

    void get_links(size_t row, std::vector<ObjKey>& result) const
    {
        MakeLinkVector mlv = MakeLinkVector(result);
        map_links(row, mlv);
    }

    mutable std::vector<ColKey> m_link_column_keys;
    std::vector<ColumnType> m_link_types;
    std::vector<ConstTableRef> m_tables;
    bool m_only_unary_links = true;
    // Leaf cache
    using LeafPtr = std::unique_ptr<ArrayPayload, PlacementDelete>;
    union Storage {
        typename std::aligned_storage<sizeof(ArrayKey), alignof(ArrayKey)>::type m_list;
        typename std::aligned_storage<sizeof(ArrayList), alignof(ArrayList)>::type m_linklist;
        typename std::aligned_storage<sizeof(ArrayList), alignof(ArrayList)>::type m_backlink;
    };
    Storage m_storage;
    LeafPtr m_array_ptr;
    const ArrayPayload* m_leaf_ptr = nullptr;

    template <class>
    friend Query compare(const Subexpr2<Link>&, const Obj&);
};

template <class T>
Value<T> make_value_for_link(bool only_unary_links, size_t size)
{
    Value<T> value;
    if (only_unary_links) {
        REALM_ASSERT(size <= 1);
        value.init(false, 1);
        value.m_storage.set_null(0);
    }
    else {
        value.init(true, size);
    }
    return value;
}

// This class can be used as untyped base for expressions that handle object properties
class ObjPropertyBase {
public:
    ObjPropertyBase(ColKey column, ConstTableRef table, std::vector<ColKey> links, ExpressionComparisonType type)
        : m_link_map(table, std::move(links))
        , m_column_key(column)
        , m_comparison_type(type)
    {
    }
    ObjPropertyBase(const ObjPropertyBase& other)
        : m_link_map(other.m_link_map)
        , m_column_key(other.m_column_key)
        , m_comparison_type(other.m_comparison_type)
    {
    }
    ObjPropertyBase(ColKey column, const LinkMap& link_map, ExpressionComparisonType type)
        : m_link_map(link_map)
        , m_column_key(column)
        , m_comparison_type(type)
    {
    }

    bool links_exist() const
    {
        return m_link_map.has_links();
    }

    bool only_unary_links() const
    {
        return m_link_map.only_unary_links();
    }

    bool is_nullable() const
    {
        return m_column_key.get_attrs().test(col_attr_Nullable);
    }

    LinkMap get_link_map() const
    {
        return m_link_map;
    }

    ColKey column_key() const noexcept
    {
        return m_column_key;
    }

protected:
    LinkMap m_link_map;
    // Column index of payload column of m_table
    mutable ColKey m_column_key;
    ExpressionComparisonType m_comparison_type; // Any, All, None
};

// Combines Subexpr2<T> and ObjPropertyBase
// Implements virtual functions defined in Expression/Subexpr
template <class T>
class ObjPropertyExpr : public Subexpr2<T>, public ObjPropertyBase {
public:
    using ObjPropertyBase::ObjPropertyBase;

    bool has_multiple_values() const override
    {
        return m_link_map.has_links() && !m_link_map.only_unary_links();
    }

    ConstTableRef get_base_table() const final
    {
        return m_link_map.get_base_table();
    }

    void set_base_table(ConstTableRef table) final
    {
        if (table != get_base_table()) {
            m_link_map.set_base_table(table);
        }
    }

    bool has_search_index() const final
    {
        auto target_table = m_link_map.get_target_table();
        return target_table->get_primary_key_column() == m_column_key || target_table->has_search_index(m_column_key);
    }

    std::vector<ObjKey> find_all(Mixed value) const final
    {
        std::vector<ObjKey> ret;
        std::vector<ObjKey> result;

        if (value.is_null() && !m_column_key.is_nullable()) {
            return ret;
        }

        if (m_link_map.get_target_table()->get_primary_key_column() == m_column_key) {
            // Only one object with a given key would be possible
            if (auto k = m_link_map.get_target_table()->find_primary_key(value))
                result.push_back(k);
        }
        else {
            StringIndex* index = m_link_map.get_target_table()->get_search_index(m_column_key);
            REALM_ASSERT(index);
            if (value.is_null()) {
                index->find_all(result, realm::null{});
            }
            else {
                T val = value.get<T>();
                index->find_all(result, val);
            }
        }

        for (ObjKey k : result) {
            auto ndxs = m_link_map.get_origin_ndxs(k);
            ret.insert(ret.end(), ndxs.begin(), ndxs.end());
        }

        return ret;
    }

    void collect_dependencies(std::vector<TableKey>& tables) const final
    {
        m_link_map.collect_dependencies(tables);
    }

    virtual std::string description(util::serializer::SerialisationState& state) const override
    {
        return state.describe_expression_type(m_comparison_type) + state.describe_columns(m_link_map, m_column_key);
    }

    virtual ExpressionComparisonType get_comparison_type() const final
    {
        return m_comparison_type;
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<Columns<T>>(static_cast<const Columns<T>&>(*this));
    }
};

// If we add a new Realm type T and quickly want Query support for it, then simply inherit from it like
// `template <> class Columns<T> : public SimpleQuerySupport<T>` and you're done. Any operators of the set
// { ==, >=, <=, !=, >, < } that are supported by T will be supported by the "query expression syntax"
// automatically. NOTE: This method of Query support will be slow because it goes through Table::get<T>.
// To get faster Query support, either add SequentialGetter support (faster) or create a query_engine.hpp
// node for it (super fast).

template <class T>
class SimpleQuerySupport : public ObjPropertyExpr<T> {
public:
    using ObjPropertyExpr<T>::links_exist;

    SimpleQuerySupport(ColKey column, ConstTableRef table, std::vector<ColKey> links = {},
                       ExpressionComparisonType type = ExpressionComparisonType::Any)
        : ObjPropertyExpr<T>(column, table, std::move(links), type)
    {
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_array_ptr = nullptr;
        m_leaf_ptr = nullptr;
        if (links_exist()) {
            m_link_map.set_cluster(cluster);
        }
        else {
            // Create new Leaf
            m_array_ptr = LeafPtr(new (&m_leaf_cache_storage) LeafType(m_link_map.get_base_table()->get_alloc()));
            cluster->init_leaf(m_column_key, m_array_ptr.get());
            m_leaf_ptr = m_array_ptr.get();
        }
    }

    void evaluate(size_t index, ValueBase& destination) override
    {
        if (links_exist()) {
            REALM_ASSERT(m_leaf_ptr == nullptr);

            if (m_link_map.only_unary_links()) {
                REALM_ASSERT(destination.size() == 1);
                REALM_ASSERT(!destination.m_from_link_list);
                destination.set_null(0);
                auto link_translation_key = this->m_link_map.get_unary_link_or_not_found(index);
                if (link_translation_key) {
                    const Obj obj = m_link_map.get_target_table()->get_object(link_translation_key);
                    if constexpr (realm::is_any_v<T, ObjectId, UUID>) {
                        auto opt_val = obj.get<util::Optional<T>>(m_column_key);
                        if (opt_val) {
                            destination.set(0, *opt_val);
                        }
                        else {
                            destination.set_null(0);
                        }
                    }
                    else {
                        destination.set(0, obj.get<T>(m_column_key));
                    }
                }
            }
            else {
                std::vector<ObjKey> links = m_link_map.get_links(index);
                destination.init(true, links.size());
                for (size_t t = 0; t < links.size(); t++) {
                    const Obj obj = m_link_map.get_target_table()->get_object(links[t]);
                    if constexpr (realm::is_any_v<T, ObjectId, UUID>) {
                        auto opt_val = obj.get<util::Optional<T>>(m_column_key);
                        if (opt_val) {
                            destination.set(t, *opt_val);
                        }
                        else {
                            destination.set_null(t);
                        }
                    }
                    else {
                        destination.set(t, obj.get<T>(m_column_key));
                    }
                }
            }
        }
        else {
            // Not a link column
            REALM_ASSERT(m_leaf_ptr != nullptr);
            REALM_ASSERT(destination.size() == 1);
            REALM_ASSERT(!destination.m_from_link_list);
            if (m_leaf_ptr->is_null(index)) {
                destination.set_null(0);
            }
            else {
                destination.set(0, m_leaf_ptr->get(index));
            }
        }
    }

    void evaluate(ObjKey key, ValueBase& destination) override
    {
        Value<T>& d = static_cast<Value<T>&>(destination);
        d.set(0, m_link_map.get_target_table()->get_object(key).template get<T>(m_column_key));
    }

    SimpleQuerySupport(const SimpleQuerySupport& other)
        : ObjPropertyExpr<T>(other)
    {
    }

    SizeOperator<T> size()
    {
        return SizeOperator<T>(this->clone());
    }

    TypeOfValueOperator<T> type_of_value()
    {
        return TypeOfValueOperator<T>(this->clone());
    }

private:
    using ObjPropertyExpr<T>::m_link_map;
    using ObjPropertyExpr<T>::m_column_key;

    // Leaf cache
    using LeafType = typename ColumnTypeTraits<T>::cluster_leaf_type;
    using LeafCacheStorage = typename std::aligned_storage<sizeof(LeafType), alignof(LeafType)>::type;
    using LeafPtr = std::unique_ptr<LeafType, PlacementDelete>;
    LeafCacheStorage m_leaf_cache_storage;
    LeafPtr m_array_ptr;
    LeafType* m_leaf_ptr = nullptr;
};

template <>
class Columns<Timestamp> : public SimpleQuerySupport<Timestamp> {
    using SimpleQuerySupport::SimpleQuerySupport;
};

template <>
class Columns<BinaryData> : public SimpleQuerySupport<BinaryData> {
    using SimpleQuerySupport::SimpleQuerySupport;
};

template <>
class Columns<ObjectId> : public SimpleQuerySupport<ObjectId> {
    using SimpleQuerySupport::SimpleQuerySupport;
};

template <>
class Columns<Decimal128> : public SimpleQuerySupport<Decimal128> {
    using SimpleQuerySupport::SimpleQuerySupport;
};

template <>
class Columns<Mixed> : public SimpleQuerySupport<Mixed> {
    using SimpleQuerySupport::SimpleQuerySupport;
};

template <>
class Columns<UUID> : public SimpleQuerySupport<UUID> {
    using SimpleQuerySupport::SimpleQuerySupport;
};

template <>
class Columns<StringData> : public SimpleQuerySupport<StringData> {
public:
    Columns(ColKey column, ConstTableRef table, std::vector<ColKey> links = {},
            ExpressionComparisonType type = ExpressionComparisonType::Any)
        : SimpleQuerySupport(column, table, links, type)
    {
    }

    Columns(Columns const& other)
        : SimpleQuerySupport(other)
    {
    }

    Columns(Columns&& other) noexcept
        : SimpleQuerySupport(other)
    {
    }
    using SimpleQuerySupport::size;
};

template <class T, class S, class I>
inline std::enable_if_t<!realm::is_any_v<T, StringData, realm::null, const char*, std::string>, Query>
string_compare(const Subexpr2<StringData>& left, T right, bool)
{
    return make_expression<Compare<Equal>>(right.clone(), left.clone());
}

template <class T, class S, class I>
inline std::enable_if_t<realm::is_any_v<T, StringData, realm::null, const char*, std::string>, Query>
string_compare(const Subexpr2<StringData>& left, T right, bool case_sensitive)
{
    StringData sd(right);
    if (case_sensitive)
        return create<S>(sd, left);
    else
        return create<I>(sd, left);
}

template <class S, class I>
Query string_compare(const Subexpr2<StringData>& left, const Subexpr2<StringData>& right, bool case_sensitive)
{
    if (case_sensitive)
        return make_expression<Compare<S>>(right.clone(), left.clone());
    else
        return make_expression<Compare<I>>(right.clone(), left.clone());
}

template <class T, class S, class I>
Query binary_compare(const Subexpr2<BinaryData>& left, T right, bool case_sensitive)
{
    BinaryData data(right);
    if (case_sensitive)
        return create<S>(data, left);
    else
        return create<I>(data, left);
}

template <class S, class I>
Query binary_compare(const Subexpr2<BinaryData>& left, const Subexpr2<BinaryData>& right, bool case_sensitive)
{
    if (case_sensitive)
        return make_expression<Compare<S>>(right.clone(), left.clone());
    else
        return make_expression<Compare<I>>(right.clone(), left.clone());
}

template <class T, class S, class I>
Query mixed_compare(const Subexpr2<Mixed>& left, T right, bool case_sensitive)
{
    Mixed data(right);
    if (case_sensitive)
        return create<S>(data, left);
    else
        return create<I>(data, left);
}

template <class S, class I>
Query mixed_compare(const Subexpr2<Mixed>& left, const Subexpr2<Mixed>& right, bool case_sensitive)
{
    if (case_sensitive)
        return make_expression<Compare<S>>(right.clone(), left.clone());
    else
        return make_expression<Compare<I>>(right.clone(), left.clone());
}

// Columns<String> == Columns<String>
inline Query operator==(const Columns<StringData>& left, const Columns<StringData>& right)
{
    return string_compare<Equal, EqualIns>(left, right, true);
}

// Columns<String> != Columns<String>
inline Query operator!=(const Columns<StringData>& left, const Columns<StringData>& right)
{
    return string_compare<NotEqual, NotEqualIns>(left, right, true);
}

// String == Columns<String>
template <class T>
Query operator==(T left, const Columns<StringData>& right)
{
    return operator==(right, left);
}

// String != Columns<String>
template <class T>
Query operator!=(T left, const Columns<StringData>& right)
{
    return operator!=(right, left);
}

// Columns<String> == String
template <class T>
Query operator==(const Columns<StringData>& left, T right)
{
    return string_compare<T, Equal, EqualIns>(left, right, true);
}

// Columns<String> != String
template <class T>
Query operator!=(const Columns<StringData>& left, T right)
{
    return string_compare<T, NotEqual, NotEqualIns>(left, right, true);
}


inline Query operator==(const Columns<BinaryData>& left, BinaryData right)
{
    return create<Equal>(right, left);
}

inline Query operator==(BinaryData left, const Columns<BinaryData>& right)
{
    return create<Equal>(left, right);
}

inline Query operator!=(const Columns<BinaryData>& left, BinaryData right)
{
    return create<NotEqual>(right, left);
}

inline Query operator!=(BinaryData left, const Columns<BinaryData>& right)
{
    return create<NotEqual>(left, right);
}

inline Query operator==(const Columns<BinaryData>& left, realm::null)
{
    return create<Equal>(BinaryData(), left);
}

inline Query operator==(realm::null, const Columns<BinaryData>& right)
{
    return create<Equal>(BinaryData(), right);
}

inline Query operator!=(const Columns<BinaryData>& left, realm::null)
{
    return create<NotEqual>(BinaryData(), left);
}

inline Query operator!=(realm::null, const Columns<BinaryData>& right)
{
    return create<NotEqual>(BinaryData(), right);
}


// This class is intended to perform queries on the *pointers* of links, contrary to performing queries on *payload*
// in linked-to tables. Queries can be "find first link that points at row X" or "find first null-link". Currently
// only "find first null link" and "find first non-null link" is supported. More will be added later. When we add
// more, I propose to remove the <bool has_links> template argument from this class and instead template it by
// a criteria-class (like the FindNullLinks class below in find_first()) in some generalized fashion.
template <bool has_links>
class UnaryLinkCompare : public Expression {
public:
    UnaryLinkCompare(const LinkMap& lm)
        : m_link_map(lm)
    {
    }

    void set_base_table(ConstTableRef table) override
    {
        m_link_map.set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_link_map.set_cluster(cluster);
    }

    void collect_dependencies(std::vector<TableKey>& tables) const override
    {
        m_link_map.collect_dependencies(tables);
    }

    // Return main table of query (table on which table->where()... is invoked). Note that this is not the same as
    // any linked-to payload tables
    ConstTableRef get_base_table() const override
    {
        return m_link_map.get_base_table();
    }

    size_t find_first(size_t start, size_t end) const override
    {
        for (; start < end;) {
            FindNullLinks fnl;
            m_link_map.map_links(start, fnl);
            if (fnl.m_has_link == has_links)
                return start;

            start++;
        }

        return not_found;
    }

    virtual std::string description(util::serializer::SerialisationState& state) const override
    {
        return state.describe_columns(m_link_map, ColKey()) + (has_links ? " != NULL" : " == NULL");
    }

    std::unique_ptr<Expression> clone() const override
    {
        return std::unique_ptr<Expression>(new UnaryLinkCompare(*this));
    }

private:
    UnaryLinkCompare(const UnaryLinkCompare& other)
        : Expression(other)
        , m_link_map(other.m_link_map)
    {
    }

    mutable LinkMap m_link_map;
};

class LinkCount : public Subexpr2<Int> {
public:
    LinkCount(const LinkMap& link_map)
        : m_link_map(link_map)
    {
    }
    LinkCount(LinkCount const& other)
        : Subexpr2<Int>(other)
        , m_link_map(other.m_link_map)
    {
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<LinkCount>(*this);
    }

    ConstTableRef get_base_table() const override
    {
        return m_link_map.get_base_table();
    }

    void set_base_table(ConstTableRef table) override
    {
        m_link_map.set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_link_map.set_cluster(cluster);
    }

    void collect_dependencies(std::vector<TableKey>& tables) const override
    {
        m_link_map.collect_dependencies(tables);
    }

    void evaluate(size_t index, ValueBase& destination) override
    {
        size_t count = m_link_map.count_links(index);
        destination = Value<int64_t>(count);
    }

    virtual std::string description(util::serializer::SerialisationState& state) const override
    {
        return state.describe_columns(m_link_map, ColKey()) + util::serializer::value_separator + "@count";
    }

private:
    LinkMap m_link_map;
};

// Gives a count of all backlinks across all columns for the specified row.
// The unused template parameter is a hack to avoid a circular dependency between table.hpp and query_expression.hpp.
template <class>
class BacklinkCount : public Subexpr2<Int> {
public:
    BacklinkCount(const LinkMap& link_map)
        : m_link_map(link_map)
    {
    }
    BacklinkCount(LinkMap&& link_map)
        : m_link_map(std::move(link_map))
    {
    }
    BacklinkCount(ConstTableRef table, std::vector<ColKey> links = {})
        : m_link_map(table, std::move(links))
    {
    }
    BacklinkCount(BacklinkCount const& other)
        : Subexpr2<Int>(other)
        , m_link_map(other.m_link_map)
    {
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<BacklinkCount<Int>>(*this);
    }

    ConstTableRef get_base_table() const override
    {
        return m_link_map.get_base_table();
    }

    void set_base_table(ConstTableRef table) override
    {
        m_link_map.set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) override
    {
        if (m_link_map.has_links()) {
            m_link_map.set_cluster(cluster);
        }
        else {
            m_keys = cluster->get_key_array();
            m_offset = cluster->get_offset();
        }
    }

    void collect_dependencies(std::vector<TableKey>& tables) const override
    {
        m_link_map.collect_dependencies(tables);
    }

    void evaluate(size_t index, ValueBase& destination) override
    {
        size_t count;
        if (m_link_map.has_links()) {
            count = m_link_map.count_all_backlinks(index);
        }
        else {
            ObjKey key(m_keys->get(index) + m_offset);
            const Obj obj = m_link_map.get_base_table()->get_object(key);
            count = obj.get_backlink_count();
        }
        destination = Value<int64_t>(count);
    }

    virtual std::string description(util::serializer::SerialisationState& state) const override
    {
        std::string s;
        if (m_link_map.links_exist()) {
            s += state.describe_columns(m_link_map, ColKey()) + util::serializer::value_separator;
        }
        s += "@links.@count";
        return s;
    }

private:
    const ClusterKeyArray* m_keys = nullptr;
    uint64_t m_offset = 0;
    LinkMap m_link_map;
};

template <class T, class TExpr>
class SizeOperator : public Subexpr2<Int> {
public:
    SizeOperator(std::unique_ptr<TExpr> left)
        : m_expr(std::move(left))
    {
    }

    SizeOperator(const SizeOperator& other)
        : m_expr(other.m_expr->clone())
    {
    }

    // See comment in base class
    void set_base_table(ConstTableRef table) override
    {
        m_expr->set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_expr->set_cluster(cluster);
    }

    // Recursively fetch tables of columns in expression tree. Used when user first builds a stand-alone expression
    // and binds it to a Query at a later time
    ConstTableRef get_base_table() const override
    {
        return m_expr->get_base_table();
    }

    // destination = operator(left)
    void evaluate(size_t index, ValueBase& destination) override
    {
        Value<T> v;
        m_expr->evaluate(index, v);

        size_t sz = v.size();
        destination.init(v.m_from_link_list, sz);

        for (size_t i = 0; i < sz; i++) {
            auto elem = v[i].template get<T>();
            if constexpr (std::is_same_v<T, int64_t>) {
                // This is the size of a list
                destination.set(i, elem);
            }
            else {
                if (!elem) {
                    destination.set_null(i);
                }
                else {
                    destination.set(i, int64_t(elem.size()));
                }
            }
        }
    }

    std::string description(util::serializer::SerialisationState& state) const override
    {
        if (m_expr) {
            return m_expr->description(state) + util::serializer::value_separator + "@size";
        }
        return "@size";
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return std::unique_ptr<Subexpr>(new SizeOperator(*this));
    }

private:
    std::unique_ptr<TExpr> m_expr;
};

template <class T>
class TypeOfValueOperator : public Subexpr2<TypeOfValue> {
public:
    TypeOfValueOperator(std::unique_ptr<Subexpr> left)
        : m_expr(std::move(left))
    {
    }

    TypeOfValueOperator(const TypeOfValueOperator& other)
        : m_expr(other.m_expr->clone())
    {
    }

    ExpressionComparisonType get_comparison_type() const override
    {
        return m_expr->get_comparison_type();
    }

    // See comment in base class
    void set_base_table(ConstTableRef table) override
    {
        m_expr->set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_expr->set_cluster(cluster);
    }

    // Recursively fetch tables of columns in expression tree. Used when user first builds a stand-alone expression
    // and binds it to a Query at a later time
    ConstTableRef get_base_table() const override
    {
        return m_expr->get_base_table();
    }

    // destination = operator(left)
    void evaluate(size_t index, ValueBase& destination) override
    {
        Value<T> v;
        m_expr->evaluate(index, v);

        size_t sz = v.size();
        destination.init(v.m_from_link_list, sz);

        for (size_t i = 0; i < sz; i++) {
            auto elem = v[i].template get<T>();
            destination.set(i, TypeOfValue(elem));
        }
    }

    std::string description(util::serializer::SerialisationState& state) const override
    {
        if (m_expr) {
            return m_expr->description(state) + util::serializer::value_separator + "@type";
        }
        return "@type";
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return std::unique_ptr<Subexpr>(new TypeOfValueOperator(*this));
    }

private:
    std::unique_ptr<Subexpr> m_expr;
};

class KeyValue : public Subexpr2<Link> {
public:
    KeyValue(ObjKey key)
        : m_key(key)
    {
    }

    void set_base_table(ConstTableRef) override {}

    ConstTableRef get_base_table() const override
    {
        return nullptr;
    }

    void evaluate(size_t, ValueBase& destination) override
    {
        destination = Value<ObjKey>(m_key);
    }

    virtual std::string description(util::serializer::SerialisationState&) const override
    {
        return util::serializer::print_value(m_key);
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return std::unique_ptr<Subexpr>(new KeyValue(*this));
    }

private:
    KeyValue(const KeyValue& source)
        : m_key(source.m_key)
    {
    }

    ObjKey m_key;
};

template <typename T>
class SubColumns;

// This is for LinkList and BackLink too since they're declared as typedefs of Link.
template <>
class Columns<Link> : public Subexpr2<Link> {
public:
    Columns(const Columns& other)
        : Subexpr2<Link>(other)
        , m_link_map(other.m_link_map)
        , m_comparison_type(other.m_comparison_type)
        , m_is_list(other.m_is_list)
    {
    }

    Query is_null()
    {
        if (m_link_map.get_nb_hops() > 1)
            throw util::runtime_error("Combining link() and is_null() is currently not supported");
        // Todo, it may be useful to support the above, but we would need to figure out an intuitive behaviour
        return make_expression<UnaryLinkCompare<false>>(m_link_map);
    }

    Query is_not_null()
    {
        if (m_link_map.get_nb_hops() > 1)
            throw util::runtime_error("Combining link() and is_not_null() is currently not supported");
        // Todo, it may be useful to support the above, but we would need to figure out an intuitive behaviour
        return make_expression<UnaryLinkCompare<true>>(m_link_map);
    }

    LinkCount count() const
    {
        return LinkCount(m_link_map);
    }

    template <class T>
    BacklinkCount<T> backlink_count() const
    {
        return BacklinkCount<T>(m_link_map);
    }

    template <typename C>
    SubColumns<C> column(ColKey column_key) const
    {
        // no need to pass along m_comparison_type because the only operations supported from
        // the subsequent SubColumns are aggregate operations such as sum, min, max, avg where
        // having
        REALM_ASSERT_DEBUG(m_comparison_type == ExpressionComparisonType::Any);
        return SubColumns<C>(Columns<C>(column_key, m_link_map.get_target_table()), m_link_map);
    }

    const LinkMap& link_map() const
    {
        return m_link_map;
    }

    DataType get_type() const override
    {
        return type_Link;
    }

    bool has_multiple_values() const override
    {
        return m_is_list || !m_link_map.only_unary_links();
    }

    ConstTableRef get_base_table() const override
    {
        return m_link_map.get_base_table();
    }

    void set_base_table(ConstTableRef table) override
    {
        m_link_map.set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) override
    {
        REALM_ASSERT(m_link_map.has_links());
        m_link_map.set_cluster(cluster);
    }

    void collect_dependencies(std::vector<TableKey>& tables) const override
    {
        m_link_map.collect_dependencies(tables);
    }

    std::string description(util::serializer::SerialisationState& state) const override
    {
        return state.describe_expression_type(m_comparison_type) + state.describe_columns(m_link_map, ColKey());
    }

    virtual ExpressionComparisonType get_comparison_type() const override
    {
        return m_comparison_type;
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return std::unique_ptr<Subexpr>(new Columns<Link>(*this));
    }

    void evaluate(size_t index, ValueBase& destination) override;

private:
    LinkMap m_link_map;
    ExpressionComparisonType m_comparison_type;
    bool m_is_list;
    friend class Table;
    friend class LinkChain;

    Columns(ColKey column_key, ConstTableRef table, const std::vector<ColKey>& links = {},
            ExpressionComparisonType type = ExpressionComparisonType::Any)
        : m_link_map(table, links)
        , m_comparison_type(type)
        , m_is_list(column_key.is_list())
    {
    }
};

template <typename T>
class ListColumns;
template <typename T, typename Operation>
class ListColumnAggregate;
namespace aggregate_operations {
template <typename T>
class Minimum;
template <typename T>
class Maximum;
template <typename T>
class Sum;
template <typename T>
class Average;
} // namespace aggregate_operations

class ColumnListBase {
public:
    ColumnListBase(ColKey column_key, ConstTableRef table, const std::vector<ColKey>& links,
                   ExpressionComparisonType type = ExpressionComparisonType::Any)
        : m_column_key(column_key)
        , m_link_map(table, links)
        , m_comparison_type(type)
    {
    }

    ColumnListBase(const ColumnListBase& other)
        : m_column_key(other.m_column_key)
        , m_link_map(other.m_link_map)
        , m_comparison_type(other.m_comparison_type)
    {
    }

    void set_cluster(const Cluster* cluster);

    void get_lists(size_t index, Value<int64_t>& destination, size_t nb_elements);

    std::string description(util::serializer::SerialisationState& state) const
    {
        return state.describe_expression_type(m_comparison_type) + state.describe_columns(m_link_map, m_column_key);
    }

    bool links_exist() const
    {
        return m_link_map.has_links();
    }

    virtual SizeOperator<int64_t> size() = 0;
    virtual std::unique_ptr<Subexpr> get_element_length() = 0;
    virtual std::unique_ptr<Subexpr> max_of() = 0;
    virtual std::unique_ptr<Subexpr> min_of() = 0;
    virtual std::unique_ptr<Subexpr> sum_of() = 0;
    virtual std::unique_ptr<Subexpr> avg_of() = 0;

    mutable ColKey m_column_key;
    LinkMap m_link_map;
    // Leaf cache
    using LeafCacheStorage = typename std::aligned_storage<sizeof(ArrayInteger), alignof(Array)>::type;
    using LeafPtr = std::unique_ptr<ArrayInteger, PlacementDelete>;
    LeafCacheStorage m_leaf_cache_storage;
    LeafPtr m_array_ptr;
    ArrayInteger* m_leaf_ptr = nullptr;
    ExpressionComparisonType m_comparison_type = ExpressionComparisonType::Any;
};

template <typename>
class ColumnListSize;

template <typename T>
class ColumnListElementLength;

template <typename T>
class ColumnsCollection : public Subexpr2<T>, public ColumnListBase {
public:
    ColumnsCollection(ColKey column_key, ConstTableRef table, const std::vector<ColKey>& links = {},
                      ExpressionComparisonType type = ExpressionComparisonType::Any)
        : ColumnListBase(column_key, table, links, type)
        , m_is_nullable_storage(this->m_column_key.get_attrs().test(col_attr_Nullable))
    {
    }

    ColumnsCollection(const ColumnsCollection& other)
        : Subexpr2<T>(other)
        , ColumnListBase(other)
        , m_is_nullable_storage(this->m_column_key.get_attrs().test(col_attr_Nullable))
    {
    }

    bool has_multiple_values() const override
    {
        return true;
    }

    ConstTableRef get_base_table() const final
    {
        return m_link_map.get_base_table();
    }

    Allocator& get_alloc() const
    {
        return m_link_map.get_target_table()->get_alloc();
    }

    void set_base_table(ConstTableRef table) final
    {
        m_link_map.set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) final
    {
        ColumnListBase::set_cluster(cluster);
    }

    void collect_dependencies(std::vector<TableKey>& tables) const final
    {
        m_link_map.collect_dependencies(tables);
    }

    void evaluate(size_t index, ValueBase& destination) override
    {
        if constexpr (realm::is_any_v<T, ObjectId, Int, Bool, UUID>) {
            if (m_is_nullable_storage) {
                evaluate<util::Optional<T>>(index, destination);
                return;
            }
        }
        evaluate<T>(index, destination);
    }

    std::string description(util::serializer::SerialisationState& state) const override
    {
        return ColumnListBase::description(state);
    }

    ExpressionComparisonType get_comparison_type() const final
    {
        return ColumnListBase::m_comparison_type;
    }

    SizeOperator<int64_t> size() override;

    ColumnListElementLength<T> element_lengths() const
    {
        return {*this};
    }

    TypeOfValueOperator<T> type_of_value()
    {
        return TypeOfValueOperator<T>(this->clone());
    }

    ListColumnAggregate<T, aggregate_operations::Minimum<T>> min() const
    {
        return {*this};
    }

    ListColumnAggregate<T, aggregate_operations::Maximum<T>> max() const
    {
        return {*this};
    }

    ListColumnAggregate<T, aggregate_operations::Sum<T>> sum() const
    {
        return {*this};
    }

    ListColumnAggregate<T, aggregate_operations::Average<T>> average() const
    {
        return {*this};
    }

    std::unique_ptr<Subexpr> max_of() override
    {
        if constexpr (realm::is_any_v<T, Int, Float, Double, Decimal128>) {
            return max().clone();
        }
        else {
            return {};
        }
    }
    std::unique_ptr<Subexpr> min_of() override
    {
        if constexpr (realm::is_any_v<T, Int, Float, Double, Decimal128>) {
            return min().clone();
        }
        else {
            return {};
        }
    }
    std::unique_ptr<Subexpr> sum_of() override
    {
        if constexpr (realm::is_any_v<T, Int, Float, Double, Decimal128>) {
            return sum().clone();
        }
        else {
            return {};
        }
    }
    std::unique_ptr<Subexpr> avg_of() override
    {
        if constexpr (realm::is_any_v<T, Int, Float, Double, Decimal128>) {
            return average().clone();
        }
        else {
            return {};
        }
    }

    std::unique_ptr<Subexpr> get_element_length() override
    {
        if constexpr (realm::is_any_v<T, StringData, BinaryData, Mixed>) {
            return element_lengths().clone();
        }
        else {
            return {};
        }
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return std::unique_ptr<Subexpr>(new ColumnsCollection(*this));
    }
    const bool m_is_nullable_storage;

private:
    template <typename StorageType>
    void evaluate(size_t index, ValueBase& destination)
    {
        Allocator& alloc = get_alloc();
        Value<int64_t> list_refs;
        get_lists(index, list_refs, 1);
        const bool is_from_list = true;

        std::vector<StorageType> values;
        for (auto&& i : list_refs) {
            ref_type list_ref = to_ref(i.get_int());
            if (list_ref) {
                BPlusTree<StorageType> list(alloc);
                list.init_from_ref(list_ref);
                size_t s = list.size();
                for (size_t j = 0; j < s; j++) {
                    values.push_back(list.get(j));
                }
            }
        }
        destination.init(is_from_list, values.size());
        destination.set(values.begin(), values.end());
    }
};

template <typename T>
class Columns<Lst<T>> : public ColumnsCollection<T> {
public:
    using ColumnsCollection<T>::ColumnsCollection;
    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<Columns<Lst<T>>>(*this);
    }
    friend class Table;
    friend class LinkChain;
};

template <typename T>
class Columns<Set<T>> : public ColumnsCollection<T> {
public:
    using ColumnsCollection<T>::ColumnsCollection;
    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<Columns<Set<T>>>(*this);
    }
};


template <>
class Columns<LnkLst> : public Columns<Lst<ObjKey>> {
public:
    using Columns<Lst<ObjKey>>::Columns;

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<Columns<LnkLst>>(*this);
    }
};

template <>
class Columns<LnkSet> : public Columns<Set<ObjKey>> {
public:
    using Columns<Set<ObjKey>>::Columns;

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<Columns<LnkSet>>(*this);
    }
};

// Returns the keys
class ColumnDictionaryKeys;

// Returns the values of a given key
class ColumnDictionaryKey;

// Returns the values
template <>
class Columns<Dictionary> : public ColumnsCollection<Mixed> {
public:
    Columns(ColKey column, ConstTableRef table, std::vector<ColKey> links = {},
            ExpressionComparisonType type = ExpressionComparisonType::Any)
        : ColumnsCollection<Mixed>(column, table, std::move(links), type)
    {
        m_key_type = m_link_map.get_target_table()->get_dictionary_key_type(column);
    }

    DataType get_key_type() const
    {
        return m_key_type;
    }

    ColumnDictionaryKey key(const Mixed& key_value);
    ColumnDictionaryKeys keys();

    SizeOperator<int64_t> size() override;
    std::unique_ptr<Subexpr> get_element_length() override
    {
        // Not supported for Dictionary
        return {};
    }
    std::unique_ptr<Subexpr> max_of() override;
    std::unique_ptr<Subexpr> min_of() override;
    std::unique_ptr<Subexpr> sum_of() override;
    std::unique_ptr<Subexpr> avg_of() override;

    void evaluate(size_t index, ValueBase& destination) override;

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<Columns<Dictionary>>(*this);
    }

    Columns(Columns const& other)
        : ColumnsCollection<Mixed>(other)
        , m_key_type(other.m_key_type)
    {
    }

protected:
    DataType m_key_type;
};

class ColumnDictionaryKey : public Columns<Dictionary> {
public:
    ColumnDictionaryKey(Mixed key_value, const Columns<Dictionary>& dict)
        : Columns<Dictionary>(dict)
    {
        init_key(key_value);
    }

    ColumnDictionaryKey& property(const std::string& prop)
    {
        m_prop_list.push_back(prop);
        return *this;
    }

    void evaluate(size_t index, ValueBase& destination) override;

    std::string description(util::serializer::SerialisationState& state) const override
    {
        return ColumnListBase::description(state) + std::string(".") + std::string(m_key.get_string());
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return std::unique_ptr<Subexpr>(new ColumnDictionaryKey(*this));
    }

    ColumnDictionaryKey(ColumnDictionaryKey const& other)
        : Columns<Dictionary>(other)
        , m_prop_list(other.m_prop_list)
        , m_objkey(other.m_objkey)
    {
        init_key(other.m_key);
    }

private:
    Mixed m_key;
    std::string m_buffer;
    std::vector<std::string> m_prop_list;
    ObjKey m_objkey;

    void init_key(Mixed key_value);
};

// Returns the keys
class ColumnDictionaryKeys : public Subexpr2<StringData> {
public:
    ColumnDictionaryKeys(const Columns<Dictionary>& dict)
        : m_key_type(dict.get_key_type())
        , m_column_key(dict.m_column_key)
        , m_link_map(dict.m_link_map)
        , m_comparison_type(dict.get_comparison_type())
    {
        REALM_ASSERT(m_key_type == type_String);
    }

    ConstTableRef get_base_table() const final
    {
        return m_link_map.get_base_table();
    }

    void set_base_table(ConstTableRef table) final
    {
        m_link_map.set_base_table(table);
    }

    void collect_dependencies(std::vector<TableKey>& tables) const final
    {
        m_link_map.collect_dependencies(tables);
    }

    ExpressionComparisonType get_comparison_type() const final
    {
        return m_comparison_type;
    }

    void set_cluster(const Cluster* cluster) override;
    void evaluate(size_t index, ValueBase& destination) override;

    std::string description(util::serializer::SerialisationState& state) const override
    {
        return state.describe_expression_type(m_comparison_type) + state.describe_columns(m_link_map, m_column_key) +
               ".keys";
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return std::unique_ptr<Subexpr>(new ColumnDictionaryKeys(*this));
    }

    ColumnDictionaryKeys(const ColumnDictionaryKeys& other)
        : m_key_type(other.m_key_type)
        , m_column_key(other.m_column_key)
        , m_link_map(other.m_link_map)
        , m_comparison_type(other.m_comparison_type)
    {
    }

private:
    DataType m_key_type;
    ColKey m_column_key;
    LinkMap m_link_map;
    ExpressionComparisonType m_comparison_type = ExpressionComparisonType::Any;


    // Leaf cache
    using LeafCacheStorage = typename std::aligned_storage<sizeof(ArrayInteger), alignof(Array)>::type;
    using LeafPtr = std::unique_ptr<ArrayInteger, PlacementDelete>;
    LeafCacheStorage m_leaf_cache_storage;
    LeafPtr m_array_ptr;
    ArrayInteger* m_leaf_ptr = nullptr;
};

template <typename T>
class ColumnListSize : public ColumnsCollection<T> {
public:
    ColumnListSize(const ColumnsCollection<T>& other)
        : ColumnsCollection<T>(other)
    {
    }
    void evaluate(size_t index, ValueBase& destination) override
    {
        if constexpr (realm::is_any_v<T, ObjectId, Int, Bool, UUID>) {
            if (this->m_is_nullable_storage) {
                evaluate<util::Optional<T>>(index, destination);
                return;
            }
        }
        evaluate<T>(index, destination);
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return std::unique_ptr<Subexpr>(new ColumnListSize<T>(*this));
    }

private:
    template <typename StorageType>
    void evaluate(size_t index, ValueBase& destination)
    {
        Allocator& alloc = ColumnsCollection<T>::get_alloc();
        Value<int64_t> list_refs;
        this->get_lists(index, list_refs, 1);
        destination.init(list_refs.m_from_link_list, list_refs.size());
        for (size_t i = 0; i < list_refs.size(); i++) {
            ref_type list_ref = to_ref(list_refs[i].get_int());
            if (list_ref) {
                BPlusTree<StorageType> list(alloc);
                list.init_from_ref(list_ref);
                size_t s = list.size();
                destination.set(i, int64_t(s));
            }
            else {
                destination.set(i, 0);
            }
        }
    }
};


template <typename T>
class ColumnListElementLength : public Subexpr2<Int> {
public:
    ColumnListElementLength(const ColumnsCollection<T>& source)
        : m_list(source)
    {
    }
    bool has_multiple_values() const override
    {
        return true;
    }
    void evaluate(size_t index, ValueBase& destination) override
    {
        Allocator& alloc = m_list.get_alloc();
        Value<int64_t> list_refs;
        m_list.get_lists(index, list_refs, 1);
        std::vector<Int> sizes;
        for (size_t i = 0; i < list_refs.size(); i++) {
            ref_type list_ref = to_ref(list_refs[i].get_int());
            if (list_ref) {
                BPlusTree<T> list(alloc);
                list.init_from_ref(list_ref);
                const size_t list_size = list.size();
                sizes.reserve(sizes.size() + list_size);
                for (size_t j = 0; j < list_size; j++) {
                    if constexpr (std::is_same_v<T, Mixed>) {
                        Mixed v = list.get(j);
                        if (!v.is_null()) {
                            if (v.get_type() == type_String) {
                                sizes.push_back(v.get_string().size());
                            }
                            else if (v.get_type() == type_Binary) {
                                sizes.push_back(v.get_binary().size());
                            }
                        }
                    }
                    else {
                        sizes.push_back(list.get(j).size());
                    }
                }
            }
        }
        constexpr bool is_from_list = true;
        destination.init(is_from_list, sizes.size());
        destination.set(sizes.begin(), sizes.end());
    }
    ConstTableRef get_base_table() const override
    {
        return m_list.get_base_table();
    }

    void set_base_table(ConstTableRef table) override
    {
        m_list.set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_list.set_cluster(cluster);
    }

    void collect_dependencies(std::vector<TableKey>& tables) const override
    {
        m_list.collect_dependencies(tables);
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return std::unique_ptr<Subexpr>(new ColumnListElementLength<T>(*this));
    }

    std::string description(util::serializer::SerialisationState& state) const override
    {
        return m_list.description(state) + util::serializer::value_separator + "length";
    }

    virtual ExpressionComparisonType get_comparison_type() const override
    {
        return m_list.get_comparison_type();
    }

private:
    ColumnsCollection<T> m_list;
};


template <typename T>
SizeOperator<int64_t> ColumnsCollection<T>::size()
{
    std::unique_ptr<Subexpr> ptr(new ColumnListSize<T>(*this));
    return SizeOperator<int64_t>(std::move(ptr));
}

template <typename T, typename Operation>
class ListColumnAggregate : public Subexpr2<decltype(Operation().result())> {
public:

    ListColumnAggregate(ColumnsCollection<T> column)
        : m_list(std::move(column))
    {
    }

    ListColumnAggregate(const ListColumnAggregate& other)
        : m_list(other.m_list)
    {
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<ListColumnAggregate>(*this);
    }

    ConstTableRef get_base_table() const override
    {
        return m_list.get_base_table();
    }

    void set_base_table(ConstTableRef table) override
    {
        m_list.set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_list.set_cluster(cluster);
    }

    void collect_dependencies(std::vector<TableKey>& tables) const override
    {
        m_list.collect_dependencies(tables);
    }

    void evaluate(size_t index, ValueBase& destination) override
    {
        Allocator& alloc = m_list.get_alloc();
        Value<int64_t> list_refs;
        m_list.get_lists(index, list_refs, 1);
        size_t sz = list_refs.size();
        REALM_ASSERT_DEBUG(sz > 0 || list_refs.m_from_link_list);
        // The result is an aggregate value for each table
        destination.init_for_links(!list_refs.m_from_link_list, sz);
        for (size_t i = 0; i < list_refs.size(); i++) {
            auto list_ref = to_ref(list_refs[i].get_int());
            Operation op;
            if (list_ref) {
                if constexpr (realm::is_any_v<T, ObjectId, Int, Bool, UUID>) {
                    if (m_list.m_is_nullable_storage) {
                        accumulate<util::Optional<T>>(op, alloc, list_ref);
                    }
                    else {
                        accumulate<T>(op, alloc, list_ref);
                    }
                }
                else {
                    accumulate<T>(op, alloc, list_ref);
                }
            }
            if (op.is_null()) {
                destination.set_null(i);
            }
            else {
                destination.set(i, op.result());
            }
        }
    }

    virtual std::string description(util::serializer::SerialisationState& state) const override
    {
        return m_list.description(state) + util::serializer::value_separator + Operation::description();
    }

private:
    template <typename StorageType>
    void accumulate(Operation& op, Allocator& alloc, ref_type list_ref)
    {
        BPlusTree<StorageType> list(alloc);
        list.init_from_ref(list_ref);
        size_t s = list.size();
        for (unsigned j = 0; j < s; j++) {
            auto v = list.get(j);
            if (!value_is_null(v)) {
                if constexpr (std::is_same_v<StorageType, util::Optional<T>>) {
                    op.accumulate(*v);
                }
                else {
                    op.accumulate(v);
                }
            }
        }
    }
    ColumnsCollection<T> m_list;
};

template <class Operator>
Query compare(const Subexpr2<Link>& left, const Obj& obj)
{
    static_assert(std::is_same_v<Operator, Equal> || std::is_same_v<Operator, NotEqual>,
                  "Links can only be compared for equality.");
    const Columns<Link>* column = dynamic_cast<const Columns<Link>*>(&left);
    if (column) {
        const LinkMap& link_map = column->link_map();
        REALM_ASSERT(link_map.get_target_table()->get_key() == obj.get_table()->get_key());
#ifdef REALM_OLDQUERY_FALLBACK
        if (link_map.get_nb_hops() == 1) {
            // We can fall back to Query::links_to for != and == operations on links, but only
            // for == on link lists. This is because negating query.links_to() is equivalent to
            // to "ALL linklist != row" rather than the "ANY linklist != row" semantics we're after.
            if (link_map.m_link_types[0] == col_type_Link ||
                (link_map.m_link_types[0] == col_type_LinkList && std::is_same_v<Operator, Equal>)) {
                ConstTableRef t = column->get_base_table();
                Query query(t);

                if (std::is_same_v<Operator, NotEqual>) {
                    // Negate the following `links_to`.
                    query.Not();
                }
                query.links_to(link_map.m_link_column_keys[0], obj.get_key());
                return query;
            }
        }
#endif
    }
    return make_expression<Compare<Operator>>(left.clone(), make_subexpr<KeyValue>(obj.get_key()));
}

inline Query operator==(const Subexpr2<Link>& left, const Obj& row)
{
    return compare<Equal>(left, row);
}
inline Query operator!=(const Subexpr2<Link>& left, const Obj& row)
{
    return compare<NotEqual>(left, row);
}
inline Query operator==(const Obj& row, const Subexpr2<Link>& right)
{
    return compare<Equal>(right, row);
}
inline Query operator!=(const Obj& row, const Subexpr2<Link>& right)
{
    return compare<NotEqual>(right, row);
}

template <class Operator>
Query compare(const Subexpr2<Link>& left, null)
{
    static_assert(std::is_same_v<Operator, Equal> || std::is_same_v<Operator, NotEqual>,
                  "Links can only be compared for equality.");
    return make_expression<Compare<Operator>>(left.clone(), make_subexpr<KeyValue>(ObjKey{}));
}

inline Query operator==(const Subexpr2<Link>& left, null)
{
    return compare<Equal>(left, null());
}
inline Query operator!=(const Subexpr2<Link>& left, null)
{
    return compare<NotEqual>(left, null());
}
inline Query operator==(null, const Subexpr2<Link>& right)
{
    return compare<Equal>(right, null());
}
inline Query operator!=(null, const Subexpr2<Link>& right)
{
    return compare<NotEqual>(right, null());
}

inline Query operator==(const Subexpr2<Link>& left, const Subexpr2<Link>& right)
{
    return make_expression<Compare<Equal>>(left.clone(), right.clone());
}
inline Query operator!=(const Subexpr2<Link>& left, const Subexpr2<Link>& right)
{
    return make_expression<Compare<NotEqual>>(left.clone(), right.clone());
}


template <class T>
class Columns : public ObjPropertyExpr<T> {
public:
    using LeafType = typename ColumnTypeTraits<T>::cluster_leaf_type;
    using ObjPropertyExpr<T>::links_exist;
    using ObjPropertyBase::is_nullable;

    Columns(ColKey column, ConstTableRef table, std::vector<ColKey> links = {},
            ExpressionComparisonType type = ExpressionComparisonType::Any)
        : ObjPropertyExpr<T>(column, table, std::move(links), type)
    {
    }

    Columns(const Columns& other)
        : ObjPropertyExpr<T>(other)
    {
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_array_ptr = nullptr;
        m_leaf_ptr = nullptr;
        if (links_exist()) {
            m_link_map.set_cluster(cluster);
        }
        else {
            // Create new Leaf
            m_array_ptr = LeafPtr(new (&m_leaf_cache_storage) LeafType(this->get_base_table()->get_alloc()));
            cluster->init_leaf(m_column_key, m_array_ptr.get());
            m_leaf_ptr = m_array_ptr.get();
        }
    }

    template <class LeafType2 = LeafType>
    void evaluate_internal(size_t index, ValueBase& destination)
    {
        using U = typename LeafType2::value_type;

        if (links_exist()) {
            REALM_ASSERT(m_leaf_ptr == nullptr);
            if (m_link_map.only_unary_links()) {
                destination.init(false, 1);
                destination.set_null(0);
                if (auto link_translation_key = m_link_map.get_unary_link_or_not_found(index)) {
                    const Obj obj = m_link_map.get_target_table()->get_object(link_translation_key);
                    if (!obj.is_null(m_column_key))
                        destination.set(0, obj.get<U>(m_column_key));
                }
            }
            else {
                // LinkList with more than 0 values. Create Value with payload for all fields
                std::vector<ObjKey> links = m_link_map.get_links(index);
                destination.init_for_links(m_link_map.only_unary_links(), links.size());

                for (size_t t = 0; t < links.size(); t++) {
                    const Obj obj = m_link_map.get_target_table()->get_object(links[t]);
                    if (obj.is_null(m_column_key))
                        destination.set_null(t);
                    else
                        destination.set(t, obj.get<U>(m_column_key));
                }
            }
        }
        else {
            REALM_ASSERT(m_leaf_ptr != nullptr);
            auto leaf = static_cast<const LeafType2*>(m_leaf_ptr);
            // Not a Link column
            size_t colsize = leaf->size();

            // Now load `ValueBase::chunk_size` rows from from the leaf into m_storage. If it's an integer
            // leaf, then it contains the method get_chunk() which copies these values in a super fast way (first
            // case of the `if` below. Otherwise, copy the values one by one in a for-loop (the `else` case).
            if constexpr (std::is_same_v<U, int64_t>) {
                if (index + ValueBase::chunk_size <= colsize) {
                    // If you want to modify 'chunk_size' then update Array::get_chunk()
                    REALM_ASSERT_3(ValueBase::chunk_size, ==, 8);

                    auto leaf_2 = static_cast<const Array*>(leaf);
                    int64_t res[ValueBase::chunk_size];
                    leaf_2->get_chunk(index, res);

                    destination.set(res, res + ValueBase::chunk_size);
                    return;
                }
            }
            size_t rows = colsize - index;
            if (rows > ValueBase::chunk_size)
                rows = ValueBase::chunk_size;
            destination.init(false, rows);

            for (size_t t = 0; t < rows; t++) {
                if (leaf->is_null(index + t)) {
                    destination.set_null(t);
                }
                else {
                    destination.set(t, leaf->get(index + t));
                }
            }
        }
    }

    virtual std::string description(util::serializer::SerialisationState& state) const override
    {
        return state.describe_expression_type(this->m_comparison_type) +
               state.describe_columns(m_link_map, m_column_key);
    }

    // Load values from Column into destination
    void evaluate(size_t index, ValueBase& destination) override
    {
        if (is_nullable() && std::is_same_v<typename LeafType::value_type, int64_t>) {
            evaluate_internal<ArrayIntNull>(index, destination);
        }
        else if (is_nullable() && std::is_same_v<typename LeafType::value_type, bool>) {
            evaluate_internal<ArrayBoolNull>(index, destination);
        }
        else {
            evaluate_internal<LeafType>(index, destination);
        }
    }

    void evaluate(ObjKey key, ValueBase& destination) override
    {
        destination.init(false, 1);
        auto table = m_link_map.get_target_table();
        auto obj = table.unchecked_ptr()->get_object(key);
        if (is_nullable() && std::is_same_v<typename LeafType::value_type, int64_t>) {
            destination.set(0, obj.template get<util::Optional<int64_t>>(m_column_key));
        }
        else if (is_nullable() && std::is_same_v<typename LeafType::value_type, bool>) {
            destination.set(0, obj.template get<util::Optional<bool>>(m_column_key));
        }
        else {
            destination.set(0, obj.template get<T>(m_column_key));
        }
    }

private:
    using ObjPropertyExpr<T>::m_link_map;
    using ObjPropertyExpr<T>::m_column_key;

    // Leaf cache
    using LeafCacheStorage = typename std::aligned_storage<sizeof(LeafType), alignof(LeafType)>::type;
    using LeafPtr = std::unique_ptr<ArrayPayload, PlacementDelete>;
    LeafCacheStorage m_leaf_cache_storage;
    LeafPtr m_array_ptr;
    const ArrayPayload* m_leaf_ptr = nullptr;
};

template <typename T, typename Operation>
class SubColumnAggregate;

// Defines a uniform interface for aggregation methods.
class SubColumnBase {
public:
    virtual std::unique_ptr<Subexpr> max_of() = 0;
    virtual std::unique_ptr<Subexpr> min_of() = 0;
    virtual std::unique_ptr<Subexpr> sum_of() = 0;
    virtual std::unique_ptr<Subexpr> avg_of() = 0;
};

template <typename T>
class SubColumns : public Subexpr, public SubColumnBase {
public:
    SubColumns(Columns<T>&& column, const LinkMap& link_map)
        : m_column(std::move(column))
        , m_link_map(link_map)
    {
    }

    DataType get_type() const final
    {
        return ColumnTypeTraits<T>::id;
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<SubColumns<T>>(*this);
    }

    ConstTableRef get_base_table() const override
    {
        return m_link_map.get_base_table();
    }

    void set_base_table(ConstTableRef table) override
    {
        m_link_map.set_base_table(table);
        m_column.set_base_table(m_link_map.get_target_table());
    }

    void collect_dependencies(std::vector<TableKey>& tables) const override
    {
        m_link_map.collect_dependencies(tables);
    }

    void evaluate(size_t, ValueBase&) override
    {
        // SubColumns can only be used in an expression in conjunction with its aggregate methods.
        REALM_ASSERT(false);
    }

    virtual std::string description(util::serializer::SerialisationState&) const override
    {
        return ""; // by itself there are no conditions, see SubColumnAggregate
    }

    SubColumnAggregate<T, aggregate_operations::Minimum<T>> min() const
    {
        return {m_column, m_link_map};
    }

    SubColumnAggregate<T, aggregate_operations::Maximum<T>> max() const
    {
        return {m_column, m_link_map};
    }

    SubColumnAggregate<T, aggregate_operations::Sum<T>> sum() const
    {
        return {m_column, m_link_map};
    }

    SubColumnAggregate<T, aggregate_operations::Average<T>> average() const
    {
        return {m_column, m_link_map};
    }

    std::unique_ptr<Subexpr> max_of() override
    {
        if constexpr (realm::is_any_v<T, Int, Float, Double, Decimal128, Timestamp>) {
            return max().clone();
        }
        else {
            return {};
        }
    }
    std::unique_ptr<Subexpr> min_of() override
    {
        if constexpr (realm::is_any_v<T, Int, Float, Double, Decimal128, Timestamp>) {
            return min().clone();
        }
        else {
            return {};
        }
    }
    std::unique_ptr<Subexpr> sum_of() override
    {
        if constexpr (realm::is_any_v<T, Int, Float, Double, Decimal128>) {
            return sum().clone();
        }
        else {
            return {};
        }
    }
    std::unique_ptr<Subexpr> avg_of() override
    {
        if constexpr (realm::is_any_v<T, Int, Float, Double, Decimal128>) {
            return average().clone();
        }
        else {
            return {};
        }
    }

private:
    Columns<T> m_column;
    LinkMap m_link_map;
};

template <typename T, typename Operation>
class SubColumnAggregate : public Subexpr2<decltype(Operation().result())> {
public:
    SubColumnAggregate(const Columns<T>& column, const LinkMap& link_map)
        : m_column(column)
        , m_link_map(link_map)
    {
    }
    SubColumnAggregate(SubColumnAggregate const& other)
        : m_column(other.m_column)
        , m_link_map(other.m_link_map)
    {
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<SubColumnAggregate>(*this);
    }

    ConstTableRef get_base_table() const override
    {
        return m_link_map.get_base_table();
    }

    void set_base_table(ConstTableRef table) override
    {
        m_link_map.set_base_table(table);
        m_column.set_base_table(m_link_map.get_target_table());
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_link_map.set_cluster(cluster);
    }

    void collect_dependencies(std::vector<TableKey>& tables) const override
    {
        m_link_map.collect_dependencies(tables);
    }

    void evaluate(size_t index, ValueBase& destination) override
    {
        std::vector<ObjKey> keys = m_link_map.get_links(index);
        std::sort(keys.begin(), keys.end());

        Operation op;
        for (auto key : keys) {
            Value<T> value;
            m_column.evaluate(key, value);
            size_t value_index = 0;
            if (!value[value_index].is_null()) {
                op.accumulate(value[value_index].template get<T>());
            }
        }
        if (op.is_null()) {
            destination.set_null(0);
        }
        else {
            destination.set(0, op.result());
        }
    }

    virtual std::string description(util::serializer::SerialisationState& state) const override
    {
        util::serializer::SerialisationState empty_state(state.class_prefix);
        return state.describe_columns(m_link_map, ColKey()) + util::serializer::value_separator +
               Operation::description() + util::serializer::value_separator + m_column.description(empty_state);
    }

private:
    Columns<T> m_column;
    LinkMap m_link_map;
};

class SubQueryCount : public Subexpr2<Int> {
public:
    SubQueryCount(const Query& q, const LinkMap& link_map)
        : m_query(q)
        , m_link_map(link_map)
    {
        REALM_ASSERT(q.produces_results_in_table_order());
        REALM_ASSERT(m_query.get_table() == m_link_map.get_target_table());
    }

    ConstTableRef get_base_table() const override
    {
        return m_link_map.get_base_table();
    }

    void set_base_table(ConstTableRef table) override
    {
        m_link_map.set_base_table(table);
        m_query.set_table(m_link_map.get_target_table().cast_away_const());
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_link_map.set_cluster(cluster);
    }

    void collect_dependencies(std::vector<TableKey>& tables) const override
    {
        m_link_map.collect_dependencies(tables);
    }

    void evaluate(size_t index, ValueBase& destination) override
    {
        std::vector<ObjKey> links = m_link_map.get_links(index);
        // std::sort(links.begin(), links.end());
        m_query.init();

        size_t count = std::accumulate(links.begin(), links.end(), size_t(0), [this](size_t running_count, ObjKey k) {
            const Obj obj = m_link_map.get_target_table()->get_object(k);
            return running_count + m_query.eval_object(obj);
        });

        destination = Value<int64_t>(count);
    }

    virtual std::string description(util::serializer::SerialisationState& state) const override
    {
        REALM_ASSERT(m_link_map.get_base_table() != nullptr);
        std::string target = state.describe_columns(m_link_map, ColKey());
        std::string var_name = state.get_variable_name(m_link_map.get_base_table());
        state.subquery_prefix_list.push_back(var_name);
        std::string desc = "SUBQUERY(" + target + ", " + var_name + ", " + m_query.get_description(state) + ")" +
                           util::serializer::value_separator + "@count";
        state.subquery_prefix_list.pop_back();
        return desc;
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<SubQueryCount>(*this);
    }

private:
    Query m_query;
    LinkMap m_link_map;
};

// The unused template parameter is a hack to avoid a circular dependency between table.hpp and query_expression.hpp.
template <class>
class SubQuery {
public:
    SubQuery(Columns<Link> link_column, Query query)
        : m_query(std::move(query))
        , m_link_map(link_column.link_map())
    {
        REALM_ASSERT(m_link_map.get_target_table() == m_query.get_table());
    }

    SubQueryCount count() const
    {
        return SubQueryCount(m_query, m_link_map);
    }

private:
    Query m_query;
    LinkMap m_link_map;
};

namespace aggregate_operations {

template <typename T, typename Compare>
class MinMaxAggregateOperator {
public:
    void accumulate(T value)
    {
        if (!is_nan(value) && (!m_result || Compare()(value, *m_result))) {
            m_result = value;
        }
    }

    bool is_null() const
    {
        return !m_result;
    }
    T result() const
    {
        return *m_result;
    }

private:
    util::Optional<T> m_result;
};

template <typename T>
class Minimum : public MinMaxAggregateOperator<T, std::less<>> {
public:
    static const char* description()
    {
        return "@min";
    }
};

template <typename T>
class Maximum : public MinMaxAggregateOperator<T, std::greater<>> {
public:
    static const char* description()
    {
        return "@max";
    }
};

template <typename T>
class Sum {
public:
    void accumulate(T value)
    {
        if (!is_nan(value)) {
            m_result += value;
        }
    }

    bool is_null() const
    {
        return false;
    }
    T result() const
    {
        return m_result;
    }
    static const char* description()
    {
        return "@sum";
    }

private:
    T m_result = {};
};

template <typename T>
class Average {
public:
    using ResultType = typename std::conditional<std::is_same_v<T, Decimal128>, Decimal128, double>::type;
    void accumulate(T value)
    {
        if (!is_nan(value)) {
            m_count++;
            m_result += value;
        }
    }

    bool is_null() const
    {
        return m_count == 0;
    }
    ResultType result() const
    {
        return m_result / m_count;
    }
    static const char* description()
    {
        return "@avg";
    }

private:
    size_t m_count = 0;
    ResultType m_result = {};
};
} // namespace aggregate_operations

template <class oper, class TLeft>
class UnaryOperator : public Subexpr2<typename oper::type> {
public:
    UnaryOperator(std::unique_ptr<TLeft> left)
        : m_left(std::move(left))
    {
    }

    UnaryOperator(const UnaryOperator& other)
        : m_left(other.m_left->clone())
    {
    }

    UnaryOperator& operator=(const UnaryOperator& other)
    {
        if (this != &other) {
            m_left = other.m_left->clone();
        }
        return *this;
    }

    UnaryOperator(UnaryOperator&&) noexcept = default;
    UnaryOperator& operator=(UnaryOperator&&) noexcept = default;

    // See comment in base class
    void set_base_table(ConstTableRef table) override
    {
        m_left->set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_left->set_cluster(cluster);
    }

    void collect_dependencies(std::vector<TableKey>& tables) const override
    {
        m_left->collect_dependencies(tables);
    }

    // Recursively fetch tables of columns in expression tree. Used when user first builds a stand-alone expression
    // and binds it to a Query at a later time
    ConstTableRef get_base_table() const override
    {
        return m_left->get_base_table();
    }

    // destination = operator(left)
    void evaluate(size_t index, ValueBase& destination) override
    {
        Value<T> result;
        Value<T> left;
        m_left->evaluate(index, left);
        result.template fun<oper>(left);
        destination = result;
    }

    virtual std::string description(util::serializer::SerialisationState& state) const override
    {
        if (m_left) {
            return m_left->description(state);
        }
        return "";
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<UnaryOperator>(*this);
    }

private:
    typedef typename oper::type T;
    std::unique_ptr<TLeft> m_left;
};


template <class oper, class TLeft, class TRight>
class Operator : public Subexpr2<typename oper::type> {
public:
    Operator(std::unique_ptr<TLeft> left, std::unique_ptr<TRight> right)
        : m_left(std::move(left))
        , m_right(std::move(right))
    {
    }

    Operator(const Operator& other)
        : m_left(other.m_left->clone())
        , m_right(other.m_right->clone())
    {
    }

    Operator& operator=(const Operator& other)
    {
        if (this != &other) {
            m_left = other.m_left->clone();
            m_right = other.m_right->clone();
        }
        return *this;
    }

    Operator(Operator&&) noexcept = default;
    Operator& operator=(Operator&&) noexcept = default;

    // See comment in base class
    void set_base_table(ConstTableRef table) override
    {
        m_left->set_base_table(table);
        m_right->set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) override
    {
        m_left->set_cluster(cluster);
        m_right->set_cluster(cluster);
    }

    // Recursively fetch tables of columns in expression tree. Used when user first builds a stand-alone expression
    // and
    // binds it to a Query at a later time
    ConstTableRef get_base_table() const override
    {
        ConstTableRef l = m_left->get_base_table();
        ConstTableRef r = m_right->get_base_table();

        // Queries do not support multiple different tables; all tables must be the same.
        REALM_ASSERT(l == nullptr || r == nullptr || l == r);

        // nullptr pointer means expression which isn't yet associated with any table, or is a Value<T>
        return bool(l) ? l : r;
    }

    // destination = operator(left, right)
    void evaluate(size_t index, ValueBase& destination) override
    {
        Value<T> result;
        Value<T> left;
        Value<T> right;
        m_left->evaluate(index, left);
        m_right->evaluate(index, right);
        result.template fun<oper>(left, right);
        destination = result;
    }

    virtual std::string description(util::serializer::SerialisationState& state) const override
    {
        std::string s;
        if (m_left) {
            s += m_left->description(state);
        }
        s += (" " + oper::description() + " ");
        if (m_right) {
            s += m_right->description(state);
        }
        return s;
    }

    std::unique_ptr<Subexpr> clone() const override
    {
        return make_subexpr<Operator>(*this);
    }

private:
    typedef typename oper::type T;
    std::unique_ptr<TLeft> m_left;
    std::unique_ptr<TRight> m_right;
};

template <class TCond>
class Compare : public Expression {
public:
    Compare(std::unique_ptr<Subexpr> left, std::unique_ptr<Subexpr> right)
        : m_left(std::move(left))
        , m_right(std::move(right))
    {
        m_left_is_const = m_left->has_constant_evaluation();
        if (m_left_is_const) {
            m_left_value = m_left->get_mixed();
        }
    }

    // See comment in base class
    void set_base_table(ConstTableRef table) override
    {
        m_left->set_base_table(table);
        m_right->set_base_table(table);
    }

    void set_cluster(const Cluster* cluster) override
    {
        if (m_has_matches) {
            m_cluster = cluster;
        }
        else {
            m_left->set_cluster(cluster);
            m_right->set_cluster(cluster);
        }
    }

    double init() override
    {
        double dT = m_left_is_const ? 10.0 : 50.0;
        if (std::is_same_v<TCond, Equal> && m_left_is_const && m_right->has_search_index() &&
            m_right->get_comparison_type() == ExpressionComparisonType::Any) {
            if (m_left_value.is_null()) {
                const ObjPropertyBase* prop = dynamic_cast<const ObjPropertyBase*>(m_right.get());
                // when checking for null across links, null links are considered matches,
                // so we must compute the slow matching even if there is an index.
                if (!prop || prop->links_exist()) {
                    return dT;
                }
                else {
                    m_matches = m_right->find_all(Mixed());
                }
            }
            else {
                if (m_right->get_type() != m_left_value.get_type()) {
                    // If the type we are looking for is not the same type as the target
                    // column, we cannot use the index
                    return dT;
                }
                m_matches = m_right->find_all(m_left_value);
            }
            // Sort
            std::sort(m_matches.begin(), m_matches.end());
            // Remove all duplicates
            m_matches.erase(std::unique(m_matches.begin(), m_matches.end()), m_matches.end());

            m_has_matches = true;
            m_index_get = 0;
            m_index_end = m_matches.size();
            dT = 0;
        }

        return dT;
    }

    // Recursively fetch tables of columns in expression tree. Used when user first builds a stand-alone expression
    // and binds it to a Query at a later time
    ConstTableRef get_base_table() const override
    {
        ConstTableRef l = m_left->get_base_table();
        ConstTableRef r = m_right->get_base_table();

        // All main tables in each subexpression of a query (table.columns() or table.link()) must be the same.
        REALM_ASSERT(l == nullptr || r == nullptr || l == r);

        // nullptr pointer means expression which isn't yet associated with any table, or is a Value<T>
        return (l) ? l : r;
    }

    void collect_dependencies(std::vector<TableKey>& tables) const override
    {
        m_left->collect_dependencies(tables);
        m_right->collect_dependencies(tables);
    }

    size_t find_first(size_t start, size_t end) const override
    {
        if (m_has_matches) {
            if (m_index_end == 0 || start >= end)
                return not_found;

            ObjKey first_key = m_cluster->get_real_key(start);
            ObjKey actual_key;

            // Sequential lookup optimization: when the query isn't constrained
            // to a LnkLst we'll get find_first() requests in ascending order,
            // so we can do a simple linear scan.
            if (m_index_get < m_index_end && m_matches[m_index_get] <= first_key) {
                actual_key = m_matches[m_index_get];
                // skip through keys which are in "earlier" leafs than the one selected by start..end:
                while (first_key > actual_key) {
                    m_index_get++;
                    if (m_index_get == m_index_end)
                        return not_found;
                    actual_key = m_matches[m_index_get];
                }
            }
            // Otherwise if we get requests out of order we have to do a more
            // expensive binary search
            else {
                auto it = std::lower_bound(m_matches.begin(), m_matches.end(), first_key);
                if (it == m_matches.end())
                    return not_found;
                actual_key = *it;
            }

            // if actual key is bigger than last key, it is not in this leaf
            ObjKey last_key = start + 1 == end ? first_key : m_cluster->get_real_key(end - 1);
            if (actual_key > last_key)
                return not_found;

            // key is known to be in this leaf, so find key whithin leaf keys
            return m_cluster->lower_bound_key(ObjKey(actual_key.value - m_cluster->get_offset()));
        }

        size_t match;
        ValueBase right;
        const ExpressionComparisonType right_cmp_type = m_right->get_comparison_type();
        if (m_left_is_const) {
            for (; start < end;) {
                m_right->evaluate(start, right);
                match = ValueBase::compare_const<TCond>(m_left_value, right, right_cmp_type);
                if (match != not_found && match + start < end)
                    return start + match;

                size_t rows = right.m_from_link_list ? 1 : right.size();
                start += rows;
            }
        }
        else {
            ValueBase left;
            const ExpressionComparisonType left_cmp_type = m_left->get_comparison_type();
            for (; start < end;) {
                m_left->evaluate(start, left);
                m_right->evaluate(start, right);
                match = ValueBase::template compare<TCond>(left, right, left_cmp_type, right_cmp_type);
                if (match != not_found && match + start < end)
                    return start + match;

                size_t rows =
                    (left.m_from_link_list || right.m_from_link_list) ? 1 : minimum(right.size(), left.size());
                start += rows;
            }
        }

        return not_found; // no match
    }

    virtual std::string description(util::serializer::SerialisationState& state) const override
    {
        if (realm::is_any_v<TCond, BeginsWith, BeginsWithIns, EndsWith, EndsWithIns, Contains, ContainsIns, Like,
                            LikeIns>) {
            // these string conditions have the arguments reversed but the order is important
            // operations ==, and != can be reversed because the produce the same results both ways
            return util::serializer::print_value(m_right->description(state) + " " + TCond::description() + " " +
                                                 m_left->description(state));
        }
        return util::serializer::print_value(m_left->description(state) + " " + TCond::description() + " " +
                                             m_right->description(state));
    }

    std::unique_ptr<Expression> clone() const override
    {
        return std::unique_ptr<Expression>(new Compare(*this));
    }

private:
    Compare(const Compare& other)
        : m_left(other.m_left->clone())
        , m_right(other.m_right->clone())
        , m_left_is_const(other.m_left_is_const)
    {
        if (m_left_is_const) {
            m_left_value = m_left->get_mixed();
        }
    }

    std::unique_ptr<Subexpr> m_left;
    std::unique_ptr<Subexpr> m_right;
    const Cluster* m_cluster;
    bool m_left_is_const;
    QueryValue m_left_value;
    bool m_has_matches = false;
    std::vector<ObjKey> m_matches;
    mutable size_t m_index_get = 0;
    size_t m_index_end = 0;
};
} // namespace realm
#endif // REALM_QUERY_EXPRESSION_HPP
