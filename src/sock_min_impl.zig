const std = @import("std");
const allocator = std.heap.c_allocator;
const print = std.debug.print;
const csock = @cImport(@cInclude("sys/socket.h"));
const c_inet_in = @cImport(@cInclude("netinet/in.h"));
const inet = @cImport(@cInclude("arpa/inet.h"));

pub fn main() !void {
    //create the socket

    const socket_fd = csock.socket(csock.AF_INET, csock.SOCK_STREAM, 0);

    if (socket_fd < 0) {
        print("socket creation failed\n", .{});
        return;
    }

    //create addr data struct
    var addr = c_inet_in.sockaddr_in{ .sin_family = csock.AF_INET, .sin_port = @intCast(inet.htons(5000)) };

    var client_addr = csock.sockaddr{};

    const client_addr_len: std.posix.socklen_t = @sizeOf(@TypeOf(client_addr));

    //bind the socket
    const bind_res = csock.bind(socket_fd, @ptrCast(&addr), @intCast(@sizeOf(@TypeOf(addr))));

    if (bind_res < 0) {
        print("bind failed\n", .{});
        return;
    }

    const listen_res = csock.listen(socket_fd, 0);

    if (listen_res < 0) {
        print("listening failed\n", .{});
        return;
    }

    var args = std.process.args();
    _ = args.skip();

    const n = try std.fmt.parseInt(u8, args.next().?, 10);
    print("n -> {any}", .{n});

    //server consistently receives new connections
    for (0..n) |_| {
        const accepted: std.posix.socket_t = csock.accept(socket_fd, &client_addr, @ptrCast(@constCast(@alignCast(&client_addr_len))));

        if (accepted < 0) {
            print("accepting failed\n", .{});
            return;
        }

        // var buff_client = std.mem.zeroes([256]u8);

        // _ = try std.posix.read(accepted, &buff_client);

        // print("accepted file -> _____\n{s}\n_____\n", .{buff_client});

        const send = try std.posix.send(accepted, "HTTP/1.1 200 OK\r\nDate: Mon, 27 Jul 2009 12:28:53 GMT\r\nServer: Apache\r\nLast-Modified: Wed, 22 Jul 2009 19:15:56 GMT\r\nETag: \"34aa387-d-1568eb00\"\r\nAccept-Ranges: bytes\r\nContent-Length: 12r\nVary: Accept-Encoding\r\nContent-Type: text/plain\r\n\r\n\nHELLO WORLD\n", 0);

        if (send < 0) {
            print("did not send\n", .{});
        }

        print("send --> {any}\n", .{send});

        std.posix.close(accepted);
    }

    std.posix.close(socket_fd);
}
