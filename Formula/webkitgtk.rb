class Webkitgtk < Formula
  desc "Full-featured Gtk+ port of the WebKit rendering engine"
  homepage "https://webkitgtk.org/"
  url "https://webkitgtk.org/releases/webkitgtk-2.10.9.tar.xz"
  sha256 "bbb18d741780b1b7fa284beb9a97361ac57cda2e42bad2ae2fcdbf797919e969"
  revision 2

  bottle do
    sha256 "65b6505ae9f248328b6128ce04bb1b0ba4e398560724eca1a80b415f1211f8c8" => :sierra
    sha256 "98c9510d518ec2d9789fea12f81e8f15ee93242a76d947b699ea053ac1525a99" => :el_capitan
    sha256 "9044470b4c61205d5a24e94c1aae72f2e8a40a409fa1c9f235a667af2f85d455" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "gtk+3"
  depends_on "libsoup"
  depends_on "enchant"
  depends_on "webp"

  needs :cxx11

  # modified version of the patch in https://bugs.webkit.org/show_bug.cgi?id=151293
  # should be included in next version
  patch :DATA

  def install
    extra_args = %w[
      -DPORT=GTK
      -DENABLE_X11_TARGET=OFF
      -DENABLE_QUARTZ_TARGET=ON
      -DENABLE_TOOLS=ON
      -DENABLE_MINIBROWSER=ON
      -DENABLE_PLUGIN_PROCESS_GTK2=OFF
      -DENABLE_VIDEO=OFF
      -DENABLE_WEB_AUDIO=OFF
      -DENABLE_CREDENTIAL_STORAGE=OFF
      -DENABLE_GEOLOCATION=OFF
      -DENABLE_OPENGL=OFF
      -DUSE_LIBNOTIFY=OFF
      -DUSE_LIBHYPHEN=OFF
      -DCMAKE_SHARED_LINKER_FLAGS=-L/path/to/nonexistent/folder
    ]

    system "cmake", ".", *(std_cmake_args + extra_args)
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <webkit2/webkit2.h>

      int main(int argc, char *argv[]) {
        fprintf(stdout, "%d.%d.%d\\n",
          webkit_get_major_version(),
          webkit_get_minor_version(),
          webkit_get_micro_version());
        return 0;
      }
    EOS
    ENV.libxml2
    atk = Formula["atk"]
    cairo = Formula["cairo"]
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gdk_pixbuf = Formula["gdk-pixbuf"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    gtkx3 = Formula["gtk+3"]
    harfbuzz = Formula["harfbuzz"]
    libepoxy = Formula["libepoxy"]
    libpng = Formula["libpng"]
    libsoup = Formula["libsoup"]
    pango = Formula["pango"]
    pixman = Formula["pixman"]
    flags = %W[
      -I#{atk.opt_include}/atk-1.0
      -I#{cairo.opt_include}/cairo
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gdk_pixbuf.opt_include}/gdk-pixbuf-2.0
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/gio-unix-2.0/
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{gtkx3.opt_include}/gtk-3.0
      -I#{harfbuzz.opt_include}/harfbuzz
      -I#{include}/webkitgtk-4.0
      -I#{libepoxy.opt_include}
      -I#{libpng.opt_include}/libpng16
      -I#{libsoup.opt_include}/libsoup-2.4
      -I#{pango.opt_include}/pango-1.0
      -I#{pixman.opt_include}/pixman-1
      -D_REENTRANT
      -L#{atk.opt_lib}
      -L#{cairo.opt_lib}
      -L#{gdk_pixbuf.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{gtkx3.opt_lib}
      -L#{libsoup.opt_lib}
      -L#{lib}
      -L#{pango.opt_lib}
      -latk-1.0
      -lcairo
      -lcairo-gobject
      -lgdk-3
      -lgdk_pixbuf-2.0
      -lgio-2.0
      -lglib-2.0
      -lgobject-2.0
      -lgtk-3
      -lintl
      -ljavascriptcoregtk-4.0
      -lpango-1.0
      -lpangocairo-1.0
      -lsoup-2.4
      -lwebkit2gtk-4.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    assert_match version.to_s, shell_output("./test")
  end
end

__END__
diff --git a/Source/WebKit2/Platform/IPC/unix/ConnectionUnix.cpp b/Source/WebKit2/Platform/IPC/unix/ConnectionUnix.cpp
index 7594cac..7e39ac0 100644
--- a/Source/WebKit2/Platform/IPC/unix/ConnectionUnix.cpp
+++ b/Source/WebKit2/Platform/IPC/unix/ConnectionUnix.cpp
@@ -43,7 +43,7 @@
 #include <gio/gio.h>
 #endif

-#if defined(SOCK_SEQPACKET)
+#if defined(SOCK_SEQPACKET) && !OS(DARWIN)
 #define SOCKET_TYPE SOCK_SEQPACKET
 #else
 #if PLATFORM(GTK)
