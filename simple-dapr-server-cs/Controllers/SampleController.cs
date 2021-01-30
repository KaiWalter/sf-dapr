namespace ControllerSample.Controllers
{
    using System;
    using System.Threading.Tasks;
    using Dapr;
    using Dapr.Client;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Logging;

    [ApiController]
    public class SampleController : ControllerBase
    {
        ILogger<SampleController> logger;

        public SampleController(ILogger<SampleController> logger)
        {
            this.logger = logger;
        }

        [HttpPost("test")]
        public ActionResult<object> Test([FromServices] DaprClient daprClient)
        {
            logger.LogDebug("Enter test");
            var o = new {
                Status = "Ok"
            };

            return new OkObjectResult(o);
        }

    }
}
