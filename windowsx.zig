// Message Crackers as per the original <windowsx.h>
const mod_root = @import("win32");
const win32 = struct {
    const L = mod_root.zig.L;
    const TRUE = mod_root.zig.TRUE;
    const FALSE = mod_root.zig.FALSE;
    const TCHAR = mod_root.zig.TCHAR;

    const BOOL = mod_root.foundation.BOOL;
    const HWND = mod_root.foundation.HWND;
    const LPARAM = mod_root.foundation.LPARAM;
    const LRESULT = mod_root.foundation.LRESULT;
    const WPARAM = mod_root.foundation.WPARAM;

    const GET_STOCK_OBJECT_FLAGS = mod_root.graphics.gdi.GET_STOCK_OBJECT_FLAGS;
    const HDC = mod_root.graphics.gdi.HDC;
    const HGDIOBJ = mod_root.graphics.gdi.HGDIOBJ;
    const HBRUSH = mod_root.graphics.gdi.HBRUSH;
    const HPEN = mod_root.graphics.gdi.HPEN;
    const HFONT = mod_root.graphics.gdi.HFONT;

    const VIRTUAL_KEY = mod_root.ui.input.keyboard_and_mouse.VIRTUAL_KEY;

    const DRAWITEMSTRUCT = mod_root.ui.controls.DRAWITEMSTRUCT;
    const HKL = mod_root.ui.text_services.HKL;
    const CREATESTRUCTW = mod_root.ui.windows_and_messaging.CREATESTRUCTW;
    const SYSTEM_PARAMETERS_INFO_ACTION = mod_root.ui.windows_and_messaging.SYSTEM_PARAMETERS_INFO_ACTION;

    const GetStockObject = mod_root.graphics.gdi.GetStockObject;
    const SelectObject = mod_root.graphics.gdi.SelectObject;
};
// ----------------------------------------------------------------------------
// WinNls.h

// String based NLS APIs
pub const LOCALE_NAME_USER_DEFAULT: ?[*:0]const win32.TCHAR = null;
pub const LOCALE_NAME_INVARIANT: ?[*:0]const win32.TCHAR = win32.L("");
pub const LOCALE_NAME_SYSTEM_DEFAULT: ?[*:0]const win32.TCHAR = win32.L("!x-sys-default-locale");

// ----------------------------------------------------------------------------
// WinGdi.h
pub const COLORREF = u32;
pub fn RGB(r: u8, g: u8, b: u8) COLORREF {
    return @as(u32, b) << 16 | @as(u32, g) << 8 | r;
}

pub fn GetRValue(rgb: COLORREF) u8 {
    return @truncate(rgb);
}
pub fn GetGValue(rgb: COLORREF) u8 {
    return @truncate(rgb >> 8);
}
pub fn GetBValue(rgb: COLORREF) u8 {
    return @truncate(rgb >> 16);
}

// ----------------------------------------------------------------------------

pub fn DeletePen(hbr: ?win32.HPEN) win32.BOOL {
    return win32.DeleteObject(@as(?win32.HGDIOBJ, hbr));
}

pub fn SelectPen(hdc: ?win32.HDC, hbr: ?win32.HPEN) ?win32.HPEN {
    // https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-selectobject#return-value
    // TODO: HGDI_ERROR is a third possible return alternative.
    return @as(?win32.HPEN, win32.SelectObject(hdc, @as(?win32.HGDIOBJ, hbr)));
}

pub fn GetStockPen(hpen: win32.GET_STOCK_OBJECT_FLAGS) ?win32.HPEN {
    return @as(?win32.HPEN, win32.GetStockObject(hpen));
}

// --------------------------------------------------------------

pub fn DeleteBrush(hbr: ?win32.HBRUSH) win32.BOOL {
    return win32.DeleteObject(@as(?win32.HGDIOBJ, hbr));
}

pub fn SelectBrush(hdc: ?win32.HDC, hbr: ?win32.HBRUSH) ?win32.HBRUSH {
    // https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-selectobject#return-value
    // TODO: HGDI_ERROR is a third possible return alternative.
    return @as(?win32.HBRUSH, win32.SelectObject(hdc, @as(?win32.HGDIOBJ, hbr)));
}

pub fn GetStockBrush(hbrush: win32.GET_STOCK_OBJECT_FLAGS) ?win32.HBRUSH {
    return @as(?win32.HBRUSH, win32.GetStockObject(hbrush));
}

// --------------------------------------------------------------

pub fn DeleteFont(hbr: ?win32.HFONT) win32.BOOL {
    return win32.DeleteObject(@as(?win32.HGDIOBJ, hbr));
}

pub fn SelectFont(hdc: ?win32.HDC, hbr: ?win32.HFONT) ?win32.HFONT {
    // https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-selectobject#return-value
    // TODO: HGDI_ERROR is a third possible return alternative.
    return @as(?win32.HFONT, win32.SelectObject(hdc, @as(?win32.HGDIOBJ, hbr)));
}

pub fn GetStockFont(hbrush: win32.GET_STOCK_OBJECT_FLAGS) ?win32.HFONT {
    return @as(?win32.HFONT, win32.GetStockObject(hbrush));
}

// ----------------------------------------------------------------------------

const forwarder_type = *const fn (hWnd: ?win32.HWND, msg: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(.winapi) win32.LRESULT;

// 0x0001 WM_CREATE
// pub fn OnCreate(self: *T, hwnd: win32.HWND, cs: *CREATESTRUCT) win32.LRESULT
pub fn HANDLE_WM_CREATE(hwnd: win32.HWND, _: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const L = packed struct {
        createstruct: *win32.CREATESTRUCTW,
    };
    const crackedL: *const L = @ptrCast(&lParam);
    // TODO: There is probably a better way of handling the return success/fail.
    return if (handler.OnCreate(hwnd, crackedL.createstruct) == 0) 0 else -1;
}

// 0x0002 WM_DESTROY
// pub fn OnDestroy(self: *T, hwnd: win32.HWND) void
pub fn HANDLE_WM_DESTROY(hwnd: win32.HWND, _: win32.WPARAM, _: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    handler.OnDestroy(hwnd);
    return 0;
}

// 0x0005 WM_SIZE
// pub fn OnSize(self: *T, hwnd: win32.HWND, state: u32, cxClient: i16, cyClient: i16) void
pub fn HANDLE_WM_SIZE(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const W = packed struct {
        state: u32,
    };
    const L = packed struct {
        cxClient: i16,
        cyClient: i16,
    };
    const crackedW: *const W = @ptrCast(&wParam);
    const crackedL: *const L = @ptrCast(&lParam);
    handler.OnSize(hwnd, crackedW.state, crackedL.cxClient, crackedL.cyClient);
    // const state = @truncate(u32, wParam);
    // const cxClient = @truncate(i16, lParam);
    // const cyClient = @truncate(i16, lParam >> 16);
    // handler.OnSize(hwnd, state, cxClient, cyClient);
    return 0;
}

// 0x0007 WM_SETFOCUS
// pub fn OnSetFocus(self: *T,  hwnd: win32.HWND, hwndOldFocus: ?win32.HWND) void
pub fn HANDLE_WM_SETFOCUS(hwnd: win32.HWND, wParam: win32.WPARAM, _: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    handler.OnSetFocus(hwnd, @as(?win32.HWND, @ptrFromInt(wParam)));
    return 0;
}

// 0x0008 WM_KILLFOCUS
// pub fn OnKillFocus(self: *T,  hwnd: win32.HWND, hwndNewFocus: ?win32.HWND) void
pub fn HANDLE_WM_KILLFOCUS(hwnd: win32.HWND, wParam: win32.WPARAM, _: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    handler.OnKillFocus(hwnd, @as(?win32.HWND, @ptrFromInt(wParam)));
    return 0;
}

// 0x000A WM_ENABLE
// pub fn OnEnable(hwnd: win32.HWND, fEnable: bool) void
pub fn HANDLE_WM_ENABLE(hwnd: win32.HWND, wParam: win32.WPARAM, _: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const fEnable: bool = if (wParam != 0) true else false;
    handler.OnEnable(hwnd, fEnable);
    return 0;
}

pub fn FORWARD_WM_ENABLE(hwnd: win32.HWND, fEnable: bool, forwarder: forwarder_type) void {
    const wParam: win32.BOOL = if (fEnable) win32.TRUE else win32.FALSE;
    _ = forwarder(hwnd, win32.WM_ENABLE, wParam, 0);
}

// TODO: 0x000B WM_SETREDRAW
// TODO: 0x000C WM_SETTEXT
// TODO: 0x000D WM_GETTEXT
// TODO: 0x000E WM_GETTEXTLENGTH

// 0x000f WM_PAINT
// pub fn OnPaint(self: *T, hwnd: win32.HWND) void
pub fn HANDLE_WM_PAINT(hwnd: win32.HWND, _: win32.WPARAM, _: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    handler.OnPaint(hwnd);
    return 0;
}

pub fn FORWARD_WM_PAINT(hwnd: win32.HWND, forwarder: forwarder_type) void {
    _ = forwarder(hwnd, win32.WM_PAINT, 0, 0);
}

// 0x0010 WM_CLOSE
// pub fn OnClose(self: *T, hwnd: win32.HWND) void
pub fn HANDLE_WM_CLOSE(hwnd: win32.HWND, _: win32.WPARAM, _: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    handler.OnClose(hwnd);
    return 0;
}

pub fn FORWARD_WM_CLOSE(hwnd: win32.HWND, forwarder: forwarder_type) void {
    _ = forwarder(hwnd, win32.WM_CLOSE, 0, 0);
}

// TODO: 0x0011 WM_QUERYENDSESSION
// TODO: 0x0012 WM_QUIT
// TODO: 0x0013 WM_QUERYOPEN
// TODO: 0x0014 WM_ERASEBKGND
// TODO: 0x0015 WM_SYSCOLORCHANGE
// TODO: 0x0016 WM_ENDSESSION
// TODO: 0x0018 WM_SHOWWINDOW

// 0x001A WM_SETTINGCHANGE
// pub fn OnSettingChange(self: *T, hwnd: win32.HWND, uiAction: SYSTEM_PARAMETERS_INFO_ACTION, lpszSectionName: ?[*:0]const TCHAR) void
pub fn HANDLE_WM_SETTINGCHANGE(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const W = packed struct {
        uiAction: win32.SYSTEM_PARAMETERS_INFO_ACTION,
    };
    const L = packed struct {
        lpszSectionName: ?[*:0]const win32.TCHAR,
    };
    const crackedW: *const W = @ptrCast(&wParam);
    const crackedL: *const L = @ptrCast(&lParam);
    handler.OnSettingChange(hwnd, crackedW.uiAction, crackedL.lpszSectionName);
    return 0;
}

// 0x002B WM_DRAWITEM
// pub fn OnDrawItem(self: *T, hwnd: win32.HWND, lpDrawItem: *const DRAWITEMSTRUCT) void
pub fn HANDLE_WM_DRAWITEM(hwnd: win32.HWND, _: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LPARAM {
    const L = packed struct {
        lpDrawItem: *const win32.DRAWITEMSTRUCT,
    };
    const crackedL: *const L = @ptrCast(&lParam);
    handler.OnDrawItem(hwnd, crackedL.lpDrawItem);
    return 0;
}

// TODO: 0x0030 WM_SETFONT
// TODO: 0x0031 WM_GETFONT
// TODO: 0x004E WM_NOTIFY

// 0x0051 WM_INPUTLANGCHANGE
// WM_INPUTLANGCHANGE is not in the original <windowsx.h>

// 0x007E WM_DISPLAYCHANGE
// pub fn OnDisplayChange(self: *T, hwnd:  win32.HWND, bitsPerPixel: u32, cxScreen: u16, cyScreen: u16) void
pub fn HANDLE_WM_DISPLAYCHANGE(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const W = packed struct {
        bitsPerPixel: u32,
    };
    const L = packed struct {
        cxScreen: u16,
        cyScreen: u16,
    };
    const crackedW: *const W = @ptrCast(&wParam);
    const crackedL: *const L = @ptrCast(&lParam);
    handler.OnDisplayChange(hwnd, crackedW.bitsPerPixel, crackedL.cxScreen, crackedL.cyScreen);
    return 0;
}

// TODO: 0x0081 WM_NCCREATE
// TODO: 0x0082 WM_NCDESTROY
// TODO: 0x0083 WM_NCCALCSIZE
// TODO: 0x0084 WM_NCHITTEST
// TODO: 0x0085 WM_NCPAINT
// TODO: 0x0086 WM_NCACTIVATE

// ---------------------------------------------------------- Key
// --------------------------------------------------------- Char
// https://stackoverflow.com/questions/8161741/handling-keyboard-input-in-win32-wm-char-or-wm-keydown-wm-keyup

const KeyW = packed struct {
    vk: win32.VIRTUAL_KEY,
};
const KeyL = packed struct {
    cRepeat: i16,
    flags: u16,
};

const CharW = packed struct {
    ch: win32.TCHAR,
};
const CharL = packed struct {
    cRepeat: i16,
};

// 0x0100 WM_KEYDOWN
// pub fn OnKey(self: *T, hwnd: win32.HWND, vk: VIRTUAL_KEY, fDown: bool, cRepeat: i16, flags: u16) void
pub fn HANDLE_WM_KEYDOWN(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const KeyW = @ptrCast(&wParam);
    const crackedL: *const KeyL = @ptrCast(&lParam);
    handler.OnKey(hwnd, crackedW.vk, true, crackedL.cRepeat, crackedL.flags);
    return 0;
}

pub fn FORWARD_WM_KEYDOWN(hwnd: win32.HWND, vk: win32.VIRTUAL_KEY, cRepeat: i16, flags: u16, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = KeyW{ .vk = vk };
    const crackedL align(@alignOf(win32.LPARAM)) = KeyL{ .cRepeat = cRepeat, .flags = flags };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    _ = forwarder(hwnd, win32.WM_KEYDOWN, wParamPtr.*, lParamPtr.*);
}

// 0x0101 WM_KEYUP
// pub fn OnKey(self: *T, hwnd: win32.HWND, vk: VIRTUAL_KEY, fDown: bool, cRepeat: i16, flags: u16) void
pub fn HANDLE_WM_KEYUP(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const KeyW = @ptrCast(&wParam);
    const crackedL: *const KeyL = @ptrCast(&lParam);
    handler.OnKey(hwnd, crackedW.vk, false, crackedL.cRepeat, crackedL.flags);
    return 0;
}

pub fn FORWARD_WM_KEYUP(hwnd: win32.HWND, vk: win32.VIRTUAL_KEY, cRepeat: i16, flags: u16, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = KeyW{ .vk = vk };
    const crackedL align(@alignOf(win32.LPARAM)) = KeyL{ .cRepeat = cRepeat, .flags = flags };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    _ = forwarder(hwnd, win32.WM_KEYUP, wParamPtr.*, lParamPtr.*);
}

// 0x0102 WM_CHAR
// pub fn OnChar(self: *T, hwnd: win32.HWND, ch: TCHAR, cRepeat: i16) void
pub fn HANDLE_WM_CHAR(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const CharW = @ptrCast(&wParam);
    const crackedL: *const CharL = @ptrCast(&lParam);
    handler.OnChar(hwnd, crackedW.ch, crackedL.cRepeat);
    return 0;
}

// 0x0103 WM_DEADCHAR
// pub fn OnDeadChar(self: *T, hwnd: win32.HWND, ch: TCHAR, cRepeat: i16) void
pub fn HANDLE_WM_DEADCHAR(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const CharW = @ptrCast(&wParam);
    const crackedL: *const CharL = @ptrCast(&lParam);
    handler.OnDeadChar(hwnd, crackedW.ch, crackedL.cRepeat);
    return 0;
}

// 0x0104 WM_SYSKEYDOWN
// pub fn OnSysKey(self: *T, hwnd: win32.HWND, vk: VIRTUAL_KEY, fDown: bool, cRepeat: i16, flags: u16) void
pub fn HANDLE_WM_SYSKEYDOWN(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const KeyW = @ptrCast(&wParam);
    const crackedL: *const KeyL = @ptrCast(&lParam);
    handler.OnSysKey(hwnd, crackedW.vk, true, crackedL.cRepeat, crackedL.flags);
    return 0;
}

pub fn FORWARD_WM_SYSKEYDOWN(hwnd: win32.HWND, vk: win32.VIRTUAL_KEY, cRepeat: i16, flags: u16, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = KeyW{ .vk = vk };
    const crackedL align(@alignOf(win32.LPARAM)) = KeyL{ .cRepeat = cRepeat, .flags = flags };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    _ = forwarder(hwnd, win32.WM_SYSKEYDOWN, wParamPtr.*, lParamPtr.*);
}

// 0x0105 WM_SYSKEYUP
// OnSysKey(self: *T, hwnd: win32.HWND, vk: VIRTUAL_KEY, fDown: bool, cRepeat: i16, flags: u16) void
pub fn HANDLE_WM_SYSKEYUP(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const KeyW = @ptrCast(&wParam);
    const crackedL: *const KeyL = @ptrCast(&lParam);
    handler.OnSysKey(hwnd, crackedW.vk, false, crackedL.cRepeat, crackedL.flags);
    return 0;
}

pub fn FORWARD_WM_SYSKEYUP(hwnd: win32.HWND, vk: win32.VIRTUAL_KEY, cRepeat: i16, flags: u16, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = KeyW{ .vk = vk };
    const crackedL align(@alignOf(win32.LPARAM)) = KeyL{ .cRepeat = cRepeat, .flags = flags };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    _ = forwarder(hwnd, win32.WM_SYSKEYUP, wParamPtr.*, lParamPtr.*);
}

// 0x0106 WM_SYSCHAR
// pub fn OnSysChar(self: *T, hwnd: win32.HWND, ch: TCHAR, cRepeat: i16) void
pub fn HANDLE_WM_SYSCHAR(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const CharW = @ptrCast(&wParam);
    const crackedL: *const CharL = @ptrCast(&lParam);
    handler.OnSysChar(hwnd, crackedW.ch, crackedL.cRepeat);
    return 0;
}

// 0x0107 WM_SYSDEADCHAR
// pub fn OnSysDeadChar(self: *T, hwnd: win32.HWND, ch: TCHAR, cRepeat: i16) void
pub fn HANDLE_WM_SYSDEADCHAR(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const CharW = @ptrCast(&wParam);
    const crackedL: *const CharL = @ptrCast(&lParam);
    handler.OnSysDeadChar(hwnd, crackedW.ch, crackedL.cRepeat);
    return 0;
}

// --------------------------------------------------------------

// TODO: 0x0110 WM_INITDIALOG

// 0x0111 WM_COMMAND
// pub fn OnCommand(self: *T, hwnd: win32.HWND, id: i16, hwndCtl: ?win32.HWND, codeNotify: u16) void
pub fn HANDLE_WM_COMMAND(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const W = packed struct {
        id: i16,
        codeNotitfy: u16,
    };
    const L = packed struct {
        hwndCtrl: ?win32.HWND,
    };
    const crackedW: *const W = @ptrCast(&wParam);
    const crackedL: *const L = @ptrCast(&lParam);
    handler.OnCommand(hwnd, crackedW.id, crackedL.hwnd, crackedW.codeNotify);
    return 0;
}

// TODO: 0x0112 WM_SYSCOMMAND

// 0x0113 WM_TIMER
// pub fn OnTimer(self: *T, hwnd: win32.HWND, id: usize) void
pub fn HANDLE_WM_TIMER(hwnd: win32.HWND, wParam: win32.WPARAM, _: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const W = packed struct { id: usize };
    const crackedW: *const W = @ptrCast(&wParam);
    handler.OnTimer(hwnd, crackedW.id);
    return 0;
}

// ------------------------------------------------------- Scroll
const ScrollW = packed struct {
    code: u16,
    pos: i16,
};
const ScrollL = packed struct {
    hwndCtrl: ?win32.HWND,
};

// 0x0114 WM_HSCROLL
// pub fn OnHScroll(self: *T, hwnd: win32.HWND, hwndCtrl: ?win32.HWND, code: u16, pos: i16) void
pub fn HANDLE_WM_HSCROLL(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const ScrollW = @ptrCast(&wParam);
    const crackedL: *const ScrollL = @ptrCast(&lParam);
    handler.OnHScroll(hwnd, crackedL.hwndCtrl, crackedW.code, crackedW.pos);
    return 0;
}

pub fn FORWARD_WM_HSCROLL(hwnd: win32.HWND, hwndCtrl: ?win32.HWND, code: u16, pos: i16, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = ScrollW{ .code = code, .pos = pos };
    const crackedL align(@alignOf(win32.LPARAM)) = ScrollL{ .hwndCtrl = hwndCtrl };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    _ = forwarder(hwnd, win32.WM_HSCROLL, wParamPtr.*, lParamPtr.*);
}

// 0x0115 WM_VSCROLL
// pub fn OnVScroll(self: *T, hwnd: win32.HWND, hwndCtrl: ?win32.HWND, code: u16, pos: i16) void
pub fn HANDLE_WM_VSCROLL(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const ScrollW = @ptrCast(&wParam);
    const crackedL: *const ScrollL = @ptrCast(&lParam);
    handler.OnVScroll(hwnd, crackedL.hwndCtrl, crackedW.code, crackedW.pos);
    return 0;
}

pub fn FORWARD_WM_VSCROLL(hwnd: win32.HWND, hwndCtrl: ?win32.HWND, code: u16, pos: i16, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = ScrollW{ .code = code, .pos = pos };
    const crackedL align(@alignOf(win32.LPARAM)) = ScrollL{ .hwndCtrl = hwndCtrl };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    _ = forwarder(hwnd, win32.WM_VSCROLL, wParamPtr.*, lParamPtr.*);
}

// --------------------------------------------------------------

// TODO: 0x0117 WM_INITMENUPOPUP
// TODO: 0x0132 WM_CTLCOLORMSGBOX
// TODO: 0x0133 WM_CTLCOLOREDIT
// TODO: 0x0134 WM_CTLCOLORLISTBOX
// TODO: 0x0135 WM_CTLCOLORBTN
// TODO: 0x0136 WM_CTLCOLORDLG
// TODO: 0x0137 WM_CTLCOLORSCROLLBAR
// TODO: 0x0138 WM_CTLCOLORSTATIC

// -------------------------------------------------------- Mouse

const MouseW = packed struct {
    keyFlags: u32,
};
const MouseL = packed struct {
    x: i16,
    y: i16,
};

// 0x0200 WM_MOUSEMOVE
// pub fn OnMouseMove(self: *T, hwnd: win32.HWND, x: i16, y: i16, keyFlags: u32) void
pub fn HANDLE_WM_MOUSEMOVE(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const MouseW = @ptrCast(&wParam);
    const crackedL: *const MouseL = @ptrCast(&lParam);
    handler.OnMouseMove(hwnd, crackedL.x, crackedL.y, crackedW.keyFlags);
    return 0;
}

pub fn FORWARD_WM_MOUSEMOVE(hwnd: win32.HWND, x: i16, y: i16, keyFlags: u32, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = MouseW{ .keyFlags = keyFlags };
    const crackedL align(@alignOf(win32.LPARAM)) = MouseL{ .x = x, .y = y };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    _ = forwarder(hwnd, win32.WM_MOUSEMOVE, wParamPtr.*, lParamPtr.*);
}

// 0x0201 WM_LBUTTONDOWN
// pub fn OnLButtonDown(self: *T, hwnd: win32.HWND, fDoubleClick: bool, x: i16, y: i16, keyFlags: u32) void
pub fn HANDLE_WM_LBUTTONDOWN(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const MouseW = @ptrCast(&wParam);
    const crackedL: *const MouseL = @ptrCast(&lParam);
    handler.OnLButtonDown(hwnd, false, crackedL.x, crackedL.y, crackedW.keyFlags);
    return 0;
}

pub fn FORWARD_WM_LBUTTONDOWN(hwnd: win32.HWND, fDoubleClick: bool, x: i16, y: i16, keyFlags: u32, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = MouseW{ .keyFlags = keyFlags };
    const crackedL align(@alignOf(win32.LPARAM)) = MouseL{ .x = x, .y = y };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    const msg = if (fDoubleClick) win32.WM_LBUTTONDBLCLK else win32.WM_LBUTTONDOWN;
    _ = forwarder(hwnd, msg, wParamPtr.*, lParamPtr.*);
}

// 0x0202 WM_LBUTTONUP
// pub fn OnLButtonUp(self: *T, hwnd: win32.HWND, x: i16, y: i16, keyFlags: u32) void
pub fn HANDLE_WM_LBUTTONUP(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const MouseW = @ptrCast(&wParam);
    const crackedL: *const MouseL = @ptrCast(&lParam);
    handler.OnLButtonUp(hwnd, crackedL.x, crackedL.y, crackedW.keyFlags);
    return 0;
}

pub fn FORWARD_WM_LBUTTONUP(hwnd: win32.HWND, x: i16, y: i16, keyFlags: u32, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = MouseW{ .keyFlags = keyFlags };
    const crackedL align(@alignOf(win32.LPARAM)) = MouseL{ .x = x, .y = y };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    _ = forwarder(hwnd, win32.WM_LBUTTONUP, wParamPtr.*, lParamPtr.*);
}

// 0x0203 WM_LBUTTONDBLCLK
// pub fn OnLButtonDown(self: *T, hwnd: win32.HWND, fDoubleClick: bool, x: i16, y: i16, keyFlags: u32) void
pub fn HANDLE_WM_LBUTTONDBLCLK(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const MouseW = @ptrCast(&wParam);
    const crackedL: *const MouseL = @ptrCast(&lParam);
    handler.OnLButtonDown(hwnd, true, crackedL.x, crackedL.y, crackedW.keyFlags);
    return 0;
}

// 0x0204 WM_RBUTTONDOWN
// pub fn OnRButtonDown(self: *T, hwnd: win32.HWND, fDoubleClick: bool, x: i16, y: i16, keyFlags: u32) void
pub fn HANDLE_WM_RBUTTONDOWN(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const MouseW = @ptrCast(&wParam);
    const crackedL: *const MouseL = @ptrCast(&lParam);
    handler.OnRButtonDown(hwnd, false, crackedL.x, crackedL.y, crackedW.keyFlags);
    return 0;
}

pub fn FORWARD_WM_RBUTTONDOWN(hwnd: win32.HWND, fDoubleClick: bool, x: i16, y: i16, keyFlags: u32, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = MouseW{ .keyFlags = keyFlags };
    const crackedL align(@alignOf(win32.LPARAM)) = MouseL{ .x = x, .y = y };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    const msg = if (fDoubleClick) win32.WM_RBUTTONDBLCLK else win32.WM_RBUTTONDOWN;
    _ = forwarder(hwnd, msg, wParamPtr.*, lParamPtr.*);
}

// 0x0205
// pub fn OnRButtonUp(self: *T, hwnd: win32.HWND, x: i16, y: i16, keyFlags: u32) void
pub fn HANDLE_WM_RBUTTONUP(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const MouseW = @ptrCast(&wParam);
    const crackedL: *const MouseL = @ptrCast(&lParam);
    handler.OnRButtonUp(hwnd, crackedL.x, crackedL.y, crackedW.keyFlags);
    return 0;
}

pub fn FORWARD_WM_RBUTTONUP(hwnd: win32.HWND, x: i16, y: i16, keyFlags: u32, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = MouseW{ .keyFlags = keyFlags };
    const crackedL align(@alignOf(win32.LPARAM)) = MouseL{ .x = x, .y = y };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    _ = forwarder(hwnd, win32.WM_RBUTTONUP, wParamPtr.*, lParamPtr.*);
}

// 0x0206 WM_RBUTTONDBLCLK
// pub fn OnRButtonDown(self: *T, hwnd: win32.HWND, fDoubleClick: bool, x: i16, y: i16, keyFlags: u32) void
pub fn HANDLE_WM_RBUTTONDBLCLK(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const MouseW = @ptrCast(&wParam);
    const crackedL: *const MouseL = @ptrCast(&lParam);
    handler.OnRButtonDown(hwnd, true, crackedL.x, crackedL.y, crackedW.keyFlags);
    return 0;
}

// 0x0207 WM_MBUTTONDOWN
// pub fn OnMButtonDown(self: *T, hwnd: win32.HWND, fDoubleClick: bool, x: i16, y: i16, keyFlags: u32) void
pub fn HANDLE_WM_MBUTTONDOWN(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const MouseW = @ptrCast(&wParam);
    const crackedL: *const MouseL = @ptrCast(&lParam);
    handler.OnMButtonDown(hwnd, false, crackedL.x, crackedL.y, crackedW.keyFlags);
    return 0;
}

pub fn FORWARD_WM_MBUTTONDOWN(hwnd: win32.HWND, fDoubleClick: bool, x: i16, y: i16, keyFlags: u32, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = MouseW{ .keyFlags = keyFlags };
    const crackedL align(@alignOf(win32.LPARAM)) = MouseL{ .x = x, .y = y };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    const msg = if (fDoubleClick) win32.WM_MBUTTONDBLCLK else win32.WM_MBUTTONDOWN;
    _ = forwarder(hwnd, msg, wParamPtr.*, lParamPtr.*);
}

// 0x0208 WM_MBUTTONUP
// pub fn OnMButtonUp(self: *T, hwnd: win32.HWND, x: i16, y: i16, keyFlags: u32) void
pub fn HANDLE_WM_MBUTTONUP(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const MouseW = @ptrCast(&wParam);
    const crackedL: *const MouseL = @ptrCast(&lParam);
    handler.OnMButtonUp(hwnd, crackedL.x, crackedL.y, crackedW.keyFlags);
    return 0;
}

pub fn FORWARD_WM_MBUTTONUP(hwnd: win32.HWND, x: i16, y: i16, keyFlags: u32, forwarder: forwarder_type) void {
    const crackedW align(@alignOf(win32.WPARAM)) = MouseW{ .keyFlags = keyFlags };
    const crackedL align(@alignOf(win32.LPARAM)) = MouseL{ .x = x, .y = y };
    const wParamPtr: *const win32.WPARAM = @ptrCast(&crackedW);
    const lParamPtr: *const win32.LPARAM = @ptrCast(&crackedL);
    _ = forwarder(hwnd, win32.WM_MBUTTONUP, wParamPtr.*, lParamPtr.*);
}

// 0x0209 WM_MBUTTONDBLCLK
// pub fn OnMButtonDown(self: *T, hwnd: win32.HWND, fDoubleClick: bool, x: i16, y: i16, keyFlags: u32) void
pub fn HANDLE_WM_MBUTTONDBLCLK(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const crackedW: *const MouseW = @ptrCast(&wParam);
    const crackedL: *const MouseL = @ptrCast(&lParam);
    handler.OnMButtonDown(hwnd, true, crackedL.x, crackedL.y, crackedW.keyFlags);
    return 0;
}

// 0x020a WM_MOUSEWHEEL
// pub fn OnMouseWheel(self: *T, hwnd: win32.HWND, x: i16, y: i16, zDelta: i16, fwKeys: u16) void
pub fn HANDLE_WM_MOUSEWHEEL(hwnd: win32.HWND, wParam: win32.WPARAM, lParam: win32.LPARAM, comptime T: type, handler: *T) win32.LRESULT {
    const W = packed struct {
        fwKeys: u16,
        zDelta: i16,
    };
    const crackedW: *const W = @ptrCast(&wParam);
    const crackedL: *const MouseL = @ptrCast(&lParam);
    handler.OnMouseWheel(hwnd, crackedL.x, crackedL.y, crackedW.zDelta, crackedW.fwKeys);
    return 0;
}

// --------------------------------------------------------------

// TODO: 0x0220 WM_MDICREATE
// TODO: 0x0221 WM_MDIDESTROY
// TODO: 0x0222 WM_MDIACTIVATE
// TODO: 0x0223 WM_MDIRESTORE
// TODO: 0x0224 WM_MDINEXT
// TODO: 0x0225 WM_MDIMAXIMIZE
// TODO: 0x0226 WM_MDITILE
// TODO: 0x0227 WM_MDICASCADE
// TODO: 0x0228 WM_MDIICONARRANGE
// TODO: 0x0229 WM_MDIGETACTIVE
// TODO: 0x0230 WM_MDISETMENU
// TODO: 0x0300 WM_CUT
// TODO: 0x0301 WM_COPY
// TODO: 0x0302 WM_PASTE
// TODO: 0x0303 WM_CLEAR
// TODO: 0x0304 WM_UNDO
// TODO: 0x0307 WM_DESTROYCLIPBOARD
// TODO: 0x0308 WM_DRAWCLIPBOARD
// TODO: 0x0309 WM_PAINTCLIPBOARD
// TODO: 0x030A WM_VSCROLLCLIPBOARD
// TODO: 0x030B WM_SIZECLIPBOARD
// TODO: 0x030C WM_ASKCBFORMATNAME
// TODO: 0x030D WM_CHANGECBCHAIN
// TODO: 0x030F WM_QUERYNEWPALETTE
// TODO: 0x0310 WM_PALETTEISCHANGING
// TODO: 0x0311 WM_PALETTECHANGED
