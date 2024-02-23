const std = @import("std");

pub fn setup_wasm(b: *std.Build, optimize: std.builtin.Mode, cflags: []const []const u8) void {
    const lib = b.addExecutable(.{
      .name = "doomz",
      .version = .{ .major = 1, .minor = 0, .patch = 0 },
      // .optimize = .ReleaseSmall, // We force ReleaseSmall for now because of too many locals
      .optimize = optimize,
      .target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
      }),
      .root_source_file = .{ .path = "src/doomgeneric_wasm.zig" },
    });
    lib.addIncludePath(.{ .cwd_relative = "./doomgeneric/doomgeneric" });
    addSourceFiles(lib, cflags);
    lib.linkLibC(); // better than linkSystemLibrary("c") for cross-compilation
    // lib.linkSystemLibrary("c");
    lib.entry = .disabled;
    lib.import_memory = true;
    lib.stack_size = 32 * 1024 * 1024;
    // lib.use_stage1 = true; // stage2 not ready
    // lib.initial_memory = 65536;
    // lib.max_memory = 65536;
    // lib.stack_size = 14752;
    // lib.export_symbol_names = &[_][]const u8{ "add" };
    // lib.rdynamic = true;
    // So we don't need to define like __stack_chk_guard and __stack_chk_fail
    // lib.stack_protector = false;

    const wasm_step = b.step("wasm", "Compile the wasm library");
    wasm_step.dependOn(&b.addInstallArtifact(lib, .{}).step);
}

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "doomz",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/z_main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.addIncludePath(.{ .cwd_relative = "./doomgeneric/doomgeneric" });
    // This option doesn't seem to work for now...
    // exe.disable_sanitize_c = true;
    // ... so we need to do this manually because doomgeneric is full of
    // undefined behavior and clang sanitizer emits illegal instruction when
    // encoutering those by zig defaults.
    const cflags = [_][]const u8{
        "-fno-sanitize=undefined",
        // Some implici declaration in doomgeneric...
        "-Wno-implicit-function-declaration",
    };
    exe.addCSourceFiles(.{
      .files = &.{
        "doomgeneric/doomgeneric/doomgeneric_sdl.c",
        "doomgeneric/doomgeneric/m_misc.c",
      },
      .flags = &cflags
    });
    addSourceFiles(exe, &cflags);
    exe.linkSystemLibrary("SDL2");
    exe.linkLibC(); // better than linkSystemLibrary("c") for cross-compilation

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/z_main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    setup_wasm(b, optimize, &cflags);
}

pub fn addSourceFiles(target: *std.Build.Step.Compile, cflags: []const []const u8) void {
    const doomgeneric_sources = [_][]const u8{
        "doomgeneric/doomgeneric/p_doors.c",
        "doomgeneric/doomgeneric/w_file_stdc.c",
        "doomgeneric/doomgeneric/i_input.c",
        "doomgeneric/doomgeneric/p_telept.c",
        "doomgeneric/doomgeneric/p_user.c",
        "doomgeneric/doomgeneric/p_ceilng.c",
        "doomgeneric/doomgeneric/p_lights.c",
        "doomgeneric/doomgeneric/p_floor.c",
        "doomgeneric/doomgeneric/p_plats.c",
        "doomgeneric/doomgeneric/p_switch.c",
        "doomgeneric/doomgeneric/p_sight.c",
        "doomgeneric/doomgeneric/p_enemy.c",
        "doomgeneric/doomgeneric/p_maputl.c",
        "doomgeneric/doomgeneric/p_map.c",
        "doomgeneric/doomgeneric/dummy.c",
        "doomgeneric/doomgeneric/d_net.c",
        "doomgeneric/doomgeneric/am_map.c",
        "doomgeneric/doomgeneric/d_event.c",
        "doomgeneric/doomgeneric/d_items.c",
        "doomgeneric/doomgeneric/d_iwad.c",
        "doomgeneric/doomgeneric/d_loop.c",
        "doomgeneric/doomgeneric/d_main.c",
        "doomgeneric/doomgeneric/d_mode.c",
        "doomgeneric/doomgeneric/doomdef.c",
        "doomgeneric/doomgeneric/doomgeneric.c",
        "doomgeneric/doomgeneric/doomstat.c",
        "doomgeneric/doomgeneric/dstrings.c",
        "doomgeneric/doomgeneric/f_finale.c",
        "doomgeneric/doomgeneric/f_wipe.c",
        "doomgeneric/doomgeneric/g_game.c",
        "doomgeneric/doomgeneric/gusconf.c",
        "doomgeneric/doomgeneric/hu_lib.c",
        "doomgeneric/doomgeneric/hu_stuff.c",
        "doomgeneric/doomgeneric/i_cdmus.c",
        "doomgeneric/doomgeneric/i_endoom.c",
        "doomgeneric/doomgeneric/i_joystick.c",
        "doomgeneric/doomgeneric/info.c",
        "doomgeneric/doomgeneric/i_scale.c",
        "doomgeneric/doomgeneric/i_sound.c",
        "doomgeneric/doomgeneric/i_system.c",
        "doomgeneric/doomgeneric/i_timer.c",
        "doomgeneric/doomgeneric/i_video.c",
        "doomgeneric/doomgeneric/m_argv.c",
        "doomgeneric/doomgeneric/m_bbox.c",
        "doomgeneric/doomgeneric/m_cheat.c",
        "doomgeneric/doomgeneric/m_config.c",
        "doomgeneric/doomgeneric/m_controls.c",
        "doomgeneric/doomgeneric/memio.c",
        "doomgeneric/doomgeneric/m_fixed.c",
        "doomgeneric/doomgeneric/m_menu.c",
        "doomgeneric/doomgeneric/m_random.c",
        "doomgeneric/doomgeneric/p_inter.c",
        "doomgeneric/doomgeneric/p_mobj.c",
        "doomgeneric/doomgeneric/p_pspr.c",
        "doomgeneric/doomgeneric/p_saveg.c",
        "doomgeneric/doomgeneric/p_setup.c",
        "doomgeneric/doomgeneric/p_spec.c",
        "doomgeneric/doomgeneric/p_tick.c",
        "doomgeneric/doomgeneric/r_bsp.c",
        "doomgeneric/doomgeneric/r_data.c",
        "doomgeneric/doomgeneric/r_draw.c",
        "doomgeneric/doomgeneric/r_main.c",
        "doomgeneric/doomgeneric/r_plane.c",
        "doomgeneric/doomgeneric/r_segs.c",
        "doomgeneric/doomgeneric/r_sky.c",
        "doomgeneric/doomgeneric/r_things.c",
        "doomgeneric/doomgeneric/sha1.c",
        "doomgeneric/doomgeneric/sounds.c",
        "doomgeneric/doomgeneric/s_sound.c",
        "doomgeneric/doomgeneric/statdump.c",
        "doomgeneric/doomgeneric/st_lib.c",
        "doomgeneric/doomgeneric/st_stuff.c",
        "doomgeneric/doomgeneric/tables.c",
        "doomgeneric/doomgeneric/v_video.c",
        "doomgeneric/doomgeneric/w_checksum.c",
        "doomgeneric/doomgeneric/w_file.c",
        "doomgeneric/doomgeneric/wi_stuff.c",
        "doomgeneric/doomgeneric/w_main.c",
        "doomgeneric/doomgeneric/w_wad.c",
        "doomgeneric/doomgeneric/z_zone.c",
    };
    target.addCSourceFiles(.{ .files = &doomgeneric_sources, .flags = cflags });
}
