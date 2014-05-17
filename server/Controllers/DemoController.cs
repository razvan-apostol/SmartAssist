using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace server.Controllers
{
    public class DemoController : Controller
    {
        public ActionResult Index()
        {
            if (Session["loggedin"] == null)
                return Redirect("/#demo");
            else
                return View("Manage");
        }

        public ActionResult Login()
        {
            Session["loggedin"] = true;

            return RedirectToAction("Index");
        }

        public ActionResult Logout()
        {
            Session["loggedin"] = null;

            return RedirectToAction("Index");
        }
	}
}