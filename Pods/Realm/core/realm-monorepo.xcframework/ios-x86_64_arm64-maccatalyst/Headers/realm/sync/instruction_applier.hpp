/*************************************************************************
 *
 * Copyright 2017 Realm Inc.
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

#ifndef REALM_SYNC_IMPL_INSTRUCTION_APPLIER_HPP
#define REALM_SYNC_IMPL_INSTRUCTION_APPLIER_HPP

#include <realm/sync/instructions.hpp>
#include <realm/sync/changeset.hpp>
#include <realm/sync/object.hpp>
#include <realm/util/logger.hpp>
#include <realm/list.hpp>
#include <realm/dictionary.hpp>

#include <tuple>

namespace realm {
namespace sync {

struct Changeset;

struct InstructionApplier {
    explicit InstructionApplier(Transaction&) noexcept;

    /// Throws BadChangesetError if application fails due to a problem with the
    /// changeset.
    ///
    /// FIXME: Consider using std::error_code instead of throwing
    /// BadChangesetError.
    void apply(const Changeset&, util::Logger*);

    void begin_apply(const Changeset&, util::Logger*) noexcept;
    void end_apply() noexcept;

protected:
    StringData get_string(InternString) const;
    StringData get_string(StringBufferRange) const;
    BinaryData get_binary(StringBufferRange) const;
#define REALM_DECLARE_INSTRUCTION_HANDLER(X) void operator()(const Instruction::X&);
    REALM_FOR_EACH_INSTRUCTION_TYPE(REALM_DECLARE_INSTRUCTION_HANDLER)
#undef REALM_DECLARE_INSTRUCTION_HANDLER
    friend struct Instruction; // to allow visitor

    template <class A>
    static void apply(A& applier, const Changeset&, util::Logger*);

    // Allows for in-place modification of changeset while applying it
    template <class A>
    static void apply(A& applier, Changeset&, util::Logger*);

    TableRef table_for_class_name(StringData) const; // Throws

    template <class... Params>
    REALM_NORETURN void bad_transaction_log(const char*, Params&&...) const;

    Transaction& m_transaction;

    template <class... Args>
    void log(const char* fmt, Args&&... args)
    {
        if (m_logger) {
            m_logger->trace(fmt, std::forward<Args>(args)...); // Throws
        }
    }

private:
    const Changeset* m_log = nullptr;
    util::Logger* m_logger = nullptr;

    TableNameBuffer m_table_name_buffer;
    InternString m_last_table_name;
    InternString m_last_field_name;
    TableRef m_last_table;
    ColKey m_last_field;
    util::Optional<Instruction::PrimaryKey> m_last_object_key;
    util::Optional<Obj> m_last_object;
    std::unique_ptr<LstBase> m_last_list;

    StringData get_table_name(const Instruction::TableInstruction&, const char* instr = "(unspecified)");
    TableRef get_table(const Instruction::TableInstruction&, const char* instr = "(unspecified)");

    // Note: This may return a non-invalid ObjKey if the key is dangling.
    ObjKey get_object_key(Table& table, const Instruction::PrimaryKey&, const char* instr = "(unspecified)") const;
    util::Optional<Obj> get_top_object(const Instruction::ObjectInstruction&, const char* instr = "(unspecified)");

    /// Resolve the path of an instruction, and invoke the callback in one of the following ways:
    ///
    /// - If the path refers to a plain field of an object, invoke as `callback(Obj&, ColKey)`.
    ///   - Note: This also covers fields where an embedded object is placed.
    /// - If the path refers to a list, invoke as `callback(LstBase&)`.
    /// - If the path refers to a list element, invoke as `callback(LstBase&, size_t index)`.
    /// - If the path refers to a dictionary, invoke as `callback(Dictionary&)`.
    /// - If the path refers to a dictionary element, invoke as `callback(Dictionary&, Mixed key)`.
    template <class F>
    void resolve_path(const Instruction::PathInstruction& instr, const char* instr_name, F&& callback);

    template <class F>
    void resolve_field(Obj& obj, InternString field, Instruction::Path::const_iterator begin,
                       Instruction::Path::const_iterator end, const char* instr_name, F&& callback);

    template <class F>
    void resolve_list_element(LstBase& list, size_t index, Instruction::Path::const_iterator begin,
                              Instruction::Path::const_iterator end, const char* instr_name, F&& callback);

    template <class F>
    void resolve_dictionary_element(Dictionary& dict, InternString key, Instruction::Path::const_iterator begin,
                                    Instruction::Path::const_iterator end, const char* instr_name, F&& callback);

    template <class F>
    void visit_payload(const Instruction::Payload&, F&& visitor);
};


// Implementation

inline InstructionApplier::InstructionApplier(Transaction& group) noexcept
    : m_transaction(group)
{
}

inline void InstructionApplier::begin_apply(const Changeset& log, util::Logger* logger) noexcept
{
    m_log = &log;
    m_logger = logger;
}

inline void InstructionApplier::end_apply() noexcept
{
    m_log = nullptr;
    m_logger = nullptr;
    m_last_table_name = InternString{};
    m_last_field_name = InternString{};
    m_last_table = TableRef{};
    m_last_field = ColKey{};
    m_last_object.reset();
    m_last_list.reset();
}

template <class A>
inline void InstructionApplier::apply(A& applier, const Changeset& changeset, util::Logger* logger)
{
    applier.begin_apply(changeset, logger);
    for (auto instr : changeset) {
        if (!instr)
            continue;
        instr->visit(applier); // Throws
    }
    applier.end_apply();
}

template <class A>
inline void InstructionApplier::apply(A& applier, Changeset& changeset, util::Logger* logger)
{
    applier.begin_apply(changeset, logger);
    for (auto instr : changeset) {
        if (!instr)
            continue;
        instr->visit(applier); // Throws
#if REALM_DEBUG
        applier.m_table_info_cache.verify();
#endif
    }
    applier.end_apply();
}

inline void InstructionApplier::apply(const Changeset& log, util::Logger* logger)
{
    apply(*this, log, logger); // Throws
}

template <class... Params>
REALM_NORETURN void InstructionApplier::bad_transaction_log(const char* msg, Params&&... params) const
{
    // FIXME: Provide a way to format strings without going through a logger implementation.
    std::stringstream ss;
    util::StreamLogger logger{ss};
    logger.error(msg, std::forward<Params>(params)...);
    // FIXME: Avoid throwing in normal program flow (since changesets can come
    // in over the network, defective changesets are part of normal program
    // flow).
    throw BadChangesetError{ss.str()};
}

} // namespace sync
} // namespace realm

#endif // REALM_SYNC_IMPL_INSTRUCTION_APPLIER_HPP
