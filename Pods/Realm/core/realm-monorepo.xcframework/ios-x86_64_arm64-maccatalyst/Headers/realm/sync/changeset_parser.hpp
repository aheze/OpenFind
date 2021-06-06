
#ifndef REALM_SYNC_CHANGESET_PARSER_HPP
#define REALM_SYNC_CHANGESET_PARSER_HPP

#include <realm/sync/changeset.hpp>
#include <realm/impl/input_stream.hpp>

namespace realm {
namespace sync {

struct ChangesetParser {
    /// Throws BadChangesetError if parsing fails.
    ///
    /// FIXME: Consider using std::error_code instead of throwing exceptions on
    /// parse errors.
    void parse(_impl::NoCopyInputStream&, InstructionHandler&);

private:
    struct State;
};

void parse_changeset(_impl::NoCopyInputStream&, Changeset& out_log);
void parse_changeset(_impl::InputStream&, Changeset& out_log);


} // namespace sync
} // namespace realm

#endif // REALM_SYNC_CHANGESET_PARSER_HPP
