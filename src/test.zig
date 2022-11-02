const std = @import("std");
const testing = std.testing;
const rand = std.rand;
const ArrayList = std.ArrayList;
const owo = @import("./owo.zig").OwOID;

test "deterministic initialization" {
    const id = owo.init(0xDEADBEEFDEADBEEFDEADBEEFDEADBEEF);
    try testing.expectEqual(id.id, 0xDEADBEEFDEADBEEFDEADBEEFDEADBEEF);

    var list = ArrayList(u8).init(testing.allocator);
    defer list.deinit();

    try id.encode(list.writer());
}

test "initialize random + format" {
    var list = ArrayList(u8).init(testing.allocator);
    defer list.deinit();
    var prng = rand.DefaultPrng.init(0xDEADBEEF);

    const id = owo.new(prng.random());

    try id.encode(list.writer());
    std.debug.print("{s}\n", .{list.items});
}