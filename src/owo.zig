// This library is based off of @bs2kbs2k's iconic uwuid package.
// Source: https://github.com/bs2kbs2k/uwuid
// It's just a zig port of that library, and is basically identical, at least I think it is.
//
// License can be found in either LICENSE-APACHE at the root, or LICENSE-MIT, copyright @bs2kbs2k.
const std = @import("std");
const time = std.time;
const rand = std.rand;
const unicode = std.unicode;

const OWOID_HEX_DIGITS = [_]u21{ 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '🥰', '😳', '🥺', '🤗', '😍', ',' };

// TODO: Probably could be optimized, deal with potential UB.

// OwOID is a 128-bit identifier that can be formatted identical to uwuid.
pub const OwOID = struct {
    id: u128 = undefined,

    // init returns a new OwOID given a valid u128, predominantly for testing.
    // If calling from some other langauge, you should probably ensure the format is similar
    // to the one generated by `new`.
    pub fn init(x: u128) OwOID {
        return OwOID{ .id = x };
    }

    // new generates a new OwOID based off of a given timestamp, with an added randomness factor.
    // The rand.Random given is expected to be initialized already.
    pub fn new(prng: rand.Random) OwOID {
        // This is essentially translated verbatim from https://github.com/bs2kbs2k/uwuid/blob/master/src/lib.rs#L25
        const ts = @bitCast(u128, time.nanoTimestamp());

        return OwOID{
            .id = (@shlExact(@divTrunc(ts, 1_000_000), 80)) + (prng.int(u128) & 0xffffffffffffffffffff),
        };
    }

    // encode writes the "OwO" representation of the OwOID.
    // This is also essentially translated verbatim from https://github.com/bs2kbs2k/uwuid/blob/master/src/lib.rs#L25
    pub fn encode(value: OwOID, writer: anytype) !void {
        var buf: [4]u8 = .{ 0, 0, 0, 0 };

        var i: u5 = 0;
        while (true) {
            const mid: u128 = @as(u128, 0) + 0b1111;
            const shift: u7 = @as(u7, i) * 4;
            const mask: u128 = @shlExact(mid, shift);
            const digit: u128 = @shrExact((value.id & mask), shift);

            // This is always guaranteed, but we should check just in case to hint to the
            // compiler that it _really_ shouldn't happen.
            if (digit >= OWOID_HEX_DIGITS.len) unreachable;

            // This is always guaranteed to be bounded within the array, so we can truncate and use as an index.
            const len = unicode.utf8Encode(OWOID_HEX_DIGITS[@truncate(usize, digit)], &buf) catch unreachable;
            _ = try writer.write(buf[0..len]);

            if (i == 31) return;
            i += 1;
        }
    }

    // format implements the formatter function required by std.fmt.format
    // it ignores all the actual formatting lol
    pub fn format(value: OwOID, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        return value.encode(writer);
    }
};
