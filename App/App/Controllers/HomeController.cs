using EasySSOdemo2.Models;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json.Linq;
using System;
using System.Diagnostics;
using System.IdentityModel.Tokens.Jwt;
using System.IO;
using System.Threading.Tasks;


namespace EasySSOdemo2.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }

        public IActionResult About()
        {
            ViewData["Message"] = "Your application description page.";

            return View();
        }

        public IActionResult Contact()
        {
            ViewData["Message"] = "Your contact page.";

            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
        [Route("success")]
        public async Task<IActionResult> success()
        {


            var req = HttpContext.Request;
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();

            var a = requestBody.Split(new Char[] { '&' });
            dynamic response = new JObject();
            var b = a[0].Split("=")[1];

            Console.WriteLine("Original token : --- {0} ", requestBody);
            var stream = b;
            var handler = new JwtSecurityTokenHandler();
            var jsonToken = handler.ReadToken(stream);
            var tokenS = handler.ReadToken(stream) as JwtSecurityToken;

            foreach (var claim in tokenS.Claims)
            {
                Console.WriteLine(claim.Type + " " + claim.Value);
                try
                {
                    response.Add(claim.Type, claim.Value);
                }

                catch
                {

                }

                //this pseudo-code is placeholder for you to implement check for valid tenants who are your customers/users/partners
                //if(Azure-tenant-is-customer)
                //{  // proceed with business logic }
                //
                //else
                //{ // Please sign up with solution first ! // fail }
            }
            return new OkObjectResult(response.ToString());
        }
        string Base64Decode(string base64EncodedData)
        {
            var base64EncodedBytes = System.Convert.FromBase64String(base64EncodedData);
            return System.Text.Encoding.UTF8.GetString(base64EncodedBytes);
        }
    }
}
