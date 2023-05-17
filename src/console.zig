const std = @import("std");

extern fn addString(ptr: [*]const u8, size: usize) void;
extern fn printString() void;

// https://github.com/daneelsan/zig-wasm-logger/blob/master/JS.zig
pub const Console = struct {
  pub const Logger = struct {
    pub const Error = error{};
    pub const Writer = std.io.Writer(void, Error, write);

    fn write(_: void, bytes: []const u8) Error!usize {
      // This function can be called with only part of the string formatted,
      // that's why we need to first acculmulate the string and then flush
      // it later with printString.
      addString(bytes.ptr, bytes.len);
      return bytes.len;
    }
  };

  const logger = Logger.Writer{ .context = {} };
  pub fn log(comptime format: []const u8, args: anytype) void {
    logger.print(format, args) catch return;
    printString();
  }
};

