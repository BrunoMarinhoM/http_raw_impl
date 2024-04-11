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
    stat: HTTP_STATUS_ENUM,

    const Self = @This();

    pub fn get_num(self: Self) !u16 {
        return switch (self.stat) {
            .ok => 200,
            .created => 201,
            .accepted => 202,
            .non_authoritative_information => 203,
            .no_content => 204,
            .reset_content => 205,
            .partial_content => 206,
            .multi_status => 207,
            .already_reported => 208,
            .im_used => 226,
            .multiple_choices => 300,
            .moved_permanently => 301,
            .found => 302,
            .see_other => 303,
            .not_modified => 304,
            .use_proxy => 305,
            .unused => 306,
            .temporary_redirect => 307,
            .permanent_redirect => 308,
            .bad_request => 400,
            .unauthorized => 401,
            .payment_required => 402,
            .forbidden => 403,
            .not_found => 404,
            .method_not_allowed => 405,
            .not_acceptable => 406,
            .proxy_auth_required => 407,
            .request_timeout => 408,
            .internal_server_error => 500,
            //TODO: implement the rest
        };
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

pub const HTTP_HEADER_FIELD = union {
    name: []const []u8,
    value: []const []u8,
    content: ?[]const []u8, //maybe this one makes sense
    vchar: ?[]const []u8, //not even a single clue
    obs_fold: ?[]const []u8, //not a clue

};

pub const HTTP_HEADER = struct {
    fields: []HTTP_HEADER_FIELD,
};

pub const HTTP_BODY = struct {};

pub const HTTP_MESSSEGE = struct {
    start_line: HTTP_START_LINE,
    header: HTTP_HEADER,
    message_body: HTTP_BODY,
};

pub fn main() !void {
    const test_s = HTTP_STATUS{ .stat = .proxy_auth_required };

    std.debug.print("{any}\n", .{try test_s.get_num()});

    return;
}
