const std = @import("std");

const doomgeneric = @cImport({
    @cInclude("m_argv.h");
});

extern fn M_FindResponseFile() void;
extern fn dg_Create() void;
extern fn D_DoomMain() void;

pub fn main() !u8 {
    // save arguments

    doomgeneric.myargc = 0;
    doomgeneric.myargv = null;

    M_FindResponseFile();

    // start doom
    std.debug.print("Starting D_DoomMain\n", .{});
    
    dg_Create();

    D_DoomMain ();

    return 0;
}

