using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Microsoft.ReportingServices.Interfaces;

namespace SSRSMultilingualRDCE
{
    /// <summary>
    /// Interface to implement for one RDCE transformation step.
    /// </summary>
    public interface ITransformation
    {
        /// <summary>
        /// Receives an XML element and returns transformed element to the sender.
        /// </summary>
        /// <param name="report">Report to convert.</param>
        /// <param name="reportContext">Report context as conveyed to the RDCE</param>
        /// <param name="userContext">User context as conveyed to the RDCE</param>
        /// <returns>Transformed report</returns>
        XElement Transform(XElement report, IReportContext reportContext, IUserContext userContext);
    }
}
