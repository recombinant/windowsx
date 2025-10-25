# windowsx
Zig port of windowsx.h

Incomplete. Additions made whenever they can be tested.

**2025/09/25**

- Update to work with Zig 0.15.2 and the latest `zigwin32`
- Refactor away from the simple catchall `everything` in `zigwin32` by
declaring individual imports from the separate `zigwin32` modules (e.g.
`foundation` and `graphics.gdi`). Caused by
[Removing `usingnamespace`](https://github.com/ziglang/zig/issues/20663)

**2025/03/26** `build.zig.zon` Updated to work with latest [zigwin32](https://github.com/marlersoft/zigwin32)

**2025/03/05** `build.zig` and `build.zig.zon` Updated to work with Zig 0.14.0
