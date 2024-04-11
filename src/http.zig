const std = @import("std");
const allocator = std.heap.c_allocator;

const HTTP_STATUS_ENUM = enum {
    ok,
    created,
    accepted,
    non_authoritative_information,
    no_content,
    reset_content,
    partial_content,
    multi_status,
    already_reported,
    im_used,
    multiple_choices,
    moved_permanently,
    found,
    see_other,
    not_modified,
    use_proxy,
    unused,
    temporary_redirect,
    permanent_redirect,
    bad_request,
    unauthorized,
    payment_required,
    forbidden,
    not_found,
    method_not_allowed,
    not_acceptable,
    proxy_auth_required,
    request_timeout,
    internal_server_error,
};

const HTTP_STATUS = struct {
    const Self = @This();
    pub fn generate_str(self: Self) []const []u8 {
        _ = self;
    }
};

const HTTP_METHOD = enum {
    get,
    post,
    put,
    delete,

    const Self = @This();

    pub fn generate_str(self: Self) []const []u8 {
        return switch (self) {
            HTTP_METHOD.get => "GET",
            HTTP_METHOD.post => "POST",
            HTTP_METHOD.put => "PUT",
            HTTP_METHOD.delete => "DELETE",
        };
    }
};

pub const HTTP_REQUEST_LINE = struct {
    method: ?HTTP_METHOD = null,
    version: ?[]const []u8 = null,
    rtarget: ?[]const []u8 = null,

    const Self = @This();

    pub fn init(self: Self, method: HTTP_METHOD, version: *[]const []u8, rtarget: *[]const []u8) void {
        self.method - method;
        self.version = version;
        self.rtarget = rtarget;
    }

    pub fn generate_str(self: Self) ![]u8 {
        return try std.mem.concat(allocator, u8, []const []u8{ self.method.generate_str(), "\r\n", self.version });
    }
};

pub const HTTP_START_LINE = struct {
    request_line: ?HTTP_REQUEST_LINE = null,
    status_line: ?HTTP_STATUS = null,

    const Self = @This();

    pub fn generate_str(self: Self) ![]u8 {
        if (self.request_line == null and
            self.status_line == null)
        {
            return error.HTTP_line_has_not_been_initated;
        }

        if (self.request_line != null and
            self.status_line != null)
        {
            return error.HTTP_line_is_unbigious;
        }

        if (self.request_line) {
            return self.status_line.?.generate_str();
        }

        return self.request_line.?.generate_str();
    }
};

pub const HTTP_HEADER = struct {};

pub const HTTP_BODY = struct {};

pub const HTTP_MESSSEGE = struct {
    start_line: HTTP_START_LINE,
    header: HTTP_HEADER,
    message_body: HTTP_BODY,
};

pub fn main() !void {
    return;
}
