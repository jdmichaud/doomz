const std = @import("std");

pub fn setup_wasm(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addSharedLibrary("zpz6128", "src/zpz-wasm.zig", .unversioned);
  
    lib.setBuildMode(mode);
    lib.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    lib.addIncludePath("./chips/");
    lib.addCSourceFiles(&.{"src/chips-impl.c"}, &.{});
    lib.linkLibC(); // better than linkSystemLibrary("c") for cross-compilation
    lib.import_memory = true;
    lib.stack_size = 32 * 1024 * 1024;
    lib.use_stage1 = true; // stage2 not ready
    // lib.initial_memory = 65536;
    // lib.max_memory = 65536;
    // lib.stack_size = 14752;
    // lib.export_symbol_names = &[_][]const u8{ "add" };
  
    const wasm_step = b.step("wasm", "Compile the wasm library");
    wasm_step.dependOn(&b.addInstallArtifact(lib).step);
} 
  
pub fn build(b: *std.build.Builder) void {
  
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});
  
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
  
    const exe = b.addExecutable("doomz", "src/z_main.zig");
  
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addIncludePath("./doomgeneric/doomgeneric");
    // Doesn't seem to work for now...
    exe.disable_sanitize_c = true;
    // ... so we need to do this manually because doomgeneric is full of
    // undefined behavior and clang sanitizer emits illegal instruction when
    // encoutering those by zig defaults.
    const cflags = [_][]const u8{
        "-fno-sanitize=undefined",
    };
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/doomgeneric_sdl.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_doors.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/w_file_stdc.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_input.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_telept.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_user.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_ceilng.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_lights.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_floor.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_plats.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_switch.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_sight.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_enemy.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_maputl.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_map.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/dummy.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_net.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/am_map.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_event.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_items.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_iwad.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_loop.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_main.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_mode.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/doomdef.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/doomgeneric.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/doomstat.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/dstrings.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/f_finale.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/f_wipe.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/g_game.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/gusconf.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/hu_lib.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/hu_stuff.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_cdmus.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_endoom.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_joystick.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/info.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_scale.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_sound.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_system.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_timer.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_video.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_argv.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_bbox.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_cheat.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_config.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_controls.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/memio.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_fixed.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_menu.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_misc.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_random.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_inter.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_mobj.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_pspr.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_saveg.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_setup.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_spec.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_tick.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_bsp.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_data.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_draw.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_main.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_plane.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_segs.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_sky.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_things.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/sha1.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/sounds.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/s_sound.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/statdump.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/st_lib.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/st_stuff.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/tables.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/v_video.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/w_checksum.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/w_file.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/wi_stuff.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/w_main.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/w_wad.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/z_zone.c"}, &cflags);
    exe.linkSystemLibrary("SDL2");
    lib.linkLibC(); // better than linkSystemLibrary("c") for cross-compilation
    exe.install();
    // exe.use_stage1 = true; // stage2 not ready

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);

    setup_wasm(b);
}
