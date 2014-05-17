using System.Web;
using System.Web.Optimization;

namespace server
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                "~/Scripts/jquery-{version}.js"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                "~/Scripts/bootstrap.js",
                "~/Scripts/respond.js"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                "~/Content/bootstrap.css",
                "~/Content/font-awesome.css",
                "~/Content/fonts.css"));

            bundles.Add(new ScriptBundle("~/bundles/grayscale").Include(
                "~/Scripts/grayscale.js"));

            bundles.Add(new ScriptBundle("~/bundles/flot").Include(
                "~/Scripts/flot/chart-data-flot.js",
                "~/Scripts/flot/excanvas.min.js",
                "~/Scripts/flot/jquery.flot.js",
                "~/Scripts/flot/jquery.flot.pie.js",
                "~/Scripts/flot/jquery.flot.resize.js",
                "~/Scripts/flot/jquery.flot.tooltip.min.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/morris").Include(
                "~/Scripts/morris/chart-data-morris.js"));
        }
    }
}
