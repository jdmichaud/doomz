

// #include "doomkeys.h"
// #include "m_argv.h"
// #include "doomgeneric.h"

// #include <stdio.h>
// #include <unistd.h>

// #include <stdbool.h>
// #include <SDL.h>

// SDL_Window* window = NULL;
// SDL_Renderer* renderer = NULL;
// SDL_Texture* texture;

// #define KEYQUEUE_SIZE 16

// static unsigned short s_KeyQueue[KEYQUEUE_SIZE];
// static unsigned int s_KeyQueueWriteIndex = 0;
// static unsigned int s_KeyQueueReadIndex = 0;

const std = @import("std");
const Console = @import("console.zig").Console;

const doomgeneric = @cImport({
    @cInclude("doomgeneric.h");
    @cInclude("m_argv.h");
});

// doomgeneric globals (eww...)
extern fn M_FindResponseFile() void;
extern fn dg_Create() void;
extern fn D_DoomMain() void;

// JS imported functions
extern fn display(ptr: [*]c_uint) void;

// For doomgeneric
extern fn bInit(resx: u16, resy: u16) void;
extern fn bDelay(ms: u32) void;
extern fn bGetTicks() void;
extern fn bSetPageTitle(title: [*]const u8) void;

const FILE = opaque {};
export fn fprintf(_: *FILE, format: [*]const u8, _: [*]const u8) i16 {
  Console.log("{*}", .{ format });
  return 0;
}

export fn printf(format: [*]const u8, _: [*]const u8) i16 {
  Console.log("{*}", .{ format });
  return 0;
}

export fn abs(v: i32) i32 {
  return std.math.absInt(v) catch 0;
}

export fn DG_Init() void {
  bInit(doomgeneric.DOOMGENERIC_RESX, doomgeneric.DOOMGENERIC_RESX);
}

export fn DG_DrawFrame() void {
  // SDL_UpdateTexture(texture, NULL, DG_ScreenBuffer, DOOMGENERIC_RESX * sizeof(uint32_t));

  // SDL_RenderClear(renderer);
  // SDL_RenderCopy(renderer, texture, NULL, NULL);
  // SDL_RenderPresent(renderer);

  // handleKeyInput();
}

export fn DG_SleepMs(ms: u32) void {
  bDelay(ms);
}

pub fn DG_GetTicksMs() u32 {
  return bGetTicks();
}

export fn DG_GetKey(pressed: *i16, doomKey: *u8) i16 {
  // if (s_KeyQueueReadIndex == s_KeyQueueWriteIndex){
    //key queue is empty
    // return 0;
  // } else {
    // unsigned short keyData = s_KeyQueue[s_KeyQueueReadIndex];
    // s_KeyQueueReadIndex++;
    // s_KeyQueueReadIndex %= KEYQUEUE_SIZE;

    // *pressed = keyData >> 8;
    // *doomKey = keyData & 0xFF;

    // return 1;
  // }

  pressed.* = 0;
  doomKey.* = 0;

  return 0;
}

export fn DG_SetWindowTitle(title: [*]const u8) void {
  bSetPageTitle(title);
}

export fn start() u8 {
    // save arguments

    doomgeneric.myargc = 0;
    doomgeneric.myargv = null;

    // M_FindResponseFile();

    // start doom
    // std.debug.print("Starting D_DoomMain\n", .{});
    Console.log("toto 1", .{});
    dg_Create();

    D_DoomMain ();

    return 0;
}

