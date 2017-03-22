using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.ReportingServices.Interfaces;
using System.Xml.Linq;
using System.Data;
using System.Data.SqlClient;

namespace SSRSMultilingualRDCE.Transformations
{
    class MyTranslator : ITransformation
    {
        private SqlConnection _sqlConn;

        public MyTranslator()
        {
            _sqlConn = new SqlConnection("server=.;Database=SSRSMultiLingual;Trusted_Connection=True");
        }

        public XElement Transform(XElement report, IReportContext reportContext, IUserContext userContext)
        {
            if(reportContext == null)
            {
                throw new ArgumentException("ReportContext not initialized");
            }

            if(!(_sqlConn.State == ConnectionState.Open)){
               _sqlConn.Open(); 
            }

            //get the users userName and look up the preferred language.
            SqlCommand cmd = new SqlCommand("SELECT Language from UserConfiguration where UserName='" + userContext.UserName + "'",_sqlConn);
            SqlDataReader sdr = cmd.ExecuteReader();
            sdr.Read();
            string language = (string) sdr["Language"];
            sdr.Close();

            //translate all textbox items (<TextRun><Value>TEXT</Value></TextRun>)
            //we will skip expressions (starting with =)
            report.Descendants().Where(x => x.Name.LocalName == "Value" && x.Parent.Name.LocalName == "TextRun" && (!x.Value.StartsWith("=")))
                .ToList()
                .ForEach(x => x.Value = Translate(x.Value, language));

            _sqlConn.Close();
            return report;
        }

        private string Translate(string p, string language)
        {
            if (string.IsNullOrEmpty(p))
            {
                return "";
            }

            string translated = p;
            //get translation from database
            SqlCommand cmd = new SqlCommand("SELECT T.Value from Translations T inner join Items I on T.Item=I.Id WHERE I.Name='"+p+"' AND T.Language='"+language+"'",_sqlConn);
            SqlDataReader sdr = cmd.ExecuteReader();
            sdr.Read();
            translated = (string)sdr["Value"];
            sdr.Close();

            //have we got a translation? Of not, fall back to Microsoft Translator
            if (string.IsNullOrEmpty(translated))
            {
                //connect to Microsoft Translator and return translation
            }
            return translated;
        }
    }
}
