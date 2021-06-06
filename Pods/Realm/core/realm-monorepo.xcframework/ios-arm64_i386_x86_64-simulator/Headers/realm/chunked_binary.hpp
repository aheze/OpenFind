/*************************************************************************
 *
 * Copyright 2019 Realm Inc.
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

#ifndef REALM_NOINST_CHUNKED_BINARY_HPP
#define REALM_NOINST_CHUNKED_BINARY_HPP

#include <realm/binary_data.hpp>
#include <realm/column_binary.hpp>
#include <realm/table.hpp>

#include <realm/util/buffer_stream.hpp>
#include <realm/impl/input_stream.hpp>


namespace realm {

/// ChunkedBinaryData manages a vector of BinaryData. It is used to facilitate
/// extracting large binaries from binary columns and tables.
class ChunkedBinaryData {
public:
    ChunkedBinaryData() {}

    ChunkedBinaryData(const BinaryData& bd)
        : m_begin{bd}
    {
    }

    ChunkedBinaryData(const BinaryIterator& bd)
        : m_begin{bd}
    {
    }

    ChunkedBinaryData(const BinaryColumn& col, size_t index)
        : m_begin{&col, index}
    {
    }

    /// size() returns the number of bytes in the chunked binary.
    /// FIXME: This operation is O(n).
    size_t size() const noexcept;

    /// is_null returns true if the chunked binary has zero chunks or if
    /// the first chunk points to the nullptr.
    bool is_null() const;

    /// FIXME: O(n)
    char operator[](size_t index) const;

    std::string hex_dump(const char* separator = " ", int min_digits = -1) const;

    void write_to(util::ResettableExpandableBufferOutputStream& out) const;

    /// copy_to() copies the chunked binary data to \a buffer of size
    /// \a buffer_size starting at \a offset in the ChunkedBinary.
    /// copy_to() copies until the end of \a buffer or the end of
    /// the ChunkedBinary whichever comes first.
    /// copy_to() returns the number of copied bytes.
    size_t copy_to(char* buffer, size_t buffer_size, size_t offset) const;

    /// copy_to() allocates a buffer of size() in \a dest and
    /// copies the chunked binary data to \a dest.
    size_t copy_to(std::unique_ptr<char[]>& dest) const;

    /// get_first_chunk() is used in situations
    /// where it is known that there is exactly one
    /// chunk. This is the case if the ChunkedBinary
    /// has been constructed from BinaryData.
    BinaryData get_first_chunk() const;

private:
    BinaryIterator m_begin;
    friend class ChunkedBinaryInputStream;
};

class ChunkedBinaryInputStream : public _impl::NoCopyInputStream {
public:
    explicit ChunkedBinaryInputStream(const ChunkedBinaryData& chunks)
        : m_it(chunks.m_begin)
    {
    }

    bool next_block(const char*& begin, const char*& end) override
    {
        BinaryData block = m_it.get_next();
        begin = block.data();
        end = begin + block.size();
        return begin != end;
    }

private:
    BinaryIterator m_it;
};

} // namespace realm

#endif // REALM_NOINST_CHUNKED_BINARY_HPP
