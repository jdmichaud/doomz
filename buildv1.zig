const std = @import("std");

pub fn setup_wasm(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addSharedLibrary("doomz", "src/doomgeneric_wasm.zig", .unversioned);

    lib.setBuildMode(mode);
    lib.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    lib.addIncludePath("./doomgeneric/doomgeneric");
    addSourceFiles(lib, &.{});
    lib.linkLibC(); // better than linkSystemLibrary("c") for cross-compilation
    // lib.linkSystemLibrary("c");
    lib.import_memory = true;
    lib.stack_size = 32 * 1024 * 1024;
    // lib.use_stage1 = true; // stage2 not ready
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
    // This option doesn't seem to work for now...
    exe.disable_sanitize_c = true;
    // ... so we need to do this manually because doomgeneric is full of
    // undefined behavior and clang sanitizer emits illegal instruction when
    // encoutering those by zig defaults.
    const cflags = [_][]const u8{
        "-fno-sanitize=undefined",
    };
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/doomgeneric_sdl.c"}, &cflags);
    exe.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_misc.c"}, &cflags);
    addSourceFiles(exe, &cflags);
    exe.linkSystemLibrary("SDL2");
    exe.linkLibC(); // better than linkSystemLibrary("c") for cross-compilation
    exe.install();
    // exe.use_stage1 = true; // stage2 not ready

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    setup_wasm(b);
}

pub fn addSourceFiles(target: *std.build.LibExeObjStep, cflags: []const []const u8) void {
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_doors.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/w_file_stdc.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_input.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_telept.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_user.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_ceilng.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_lights.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_floor.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_plats.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_switch.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_sight.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_enemy.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_maputl.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_map.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/dummy.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_net.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/am_map.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_event.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_items.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_iwad.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_loop.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_main.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/d_mode.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/doomdef.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/doomgeneric.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/doomstat.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/dstrings.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/f_finale.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/f_wipe.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/g_game.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/gusconf.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/hu_lib.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/hu_stuff.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_cdmus.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_endoom.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_joystick.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/info.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_scale.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_sound.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_system.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_timer.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/i_video.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_argv.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_bbox.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_cheat.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_config.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_controls.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/memio.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_fixed.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_menu.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/m_random.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_inter.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_mobj.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_pspr.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_saveg.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_setup.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_spec.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/p_tick.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_bsp.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_data.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_draw.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_main.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_plane.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_segs.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_sky.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/r_things.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/sha1.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/sounds.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/s_sound.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/statdump.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/st_lib.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/st_stuff.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/tables.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/v_video.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/w_checksum.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/w_file.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/wi_stuff.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/w_main.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/w_wad.c"}, cflags);
    target.addCSourceFiles(&.{"doomgeneric/doomgeneric/z_zone.c"}, cflags);
}
