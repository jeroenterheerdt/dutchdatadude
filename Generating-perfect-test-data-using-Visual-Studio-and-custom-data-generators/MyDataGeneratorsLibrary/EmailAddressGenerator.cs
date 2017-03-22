using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Data.Schema.Tools.DataGenerator;
using Microsoft.Data.Schema.Sql;
using MyDataGeneratorsLibrary;
using Microsoft.Data.Schema.Extensibility;

namespace MyDataGeneratorsLibrary
{
    [DatabaseSchemaProviderCompatibility(typeof(SqlDatabaseSchemaProvider))]
    public class EmailAddressGenerator: Generator
    {
        
        private string _output;
        [Output(Description = " Default output ", Name = " Default output ")]
        public string Output
        {
            get { return _output; }
        }

        private List<string> validExtensions = new List<string>() {
            "AC","AD","AE","AERO","AF","AG","AI","AL","AM","AN","AO","AQ","AR","ARPA","AS","ASIA","AT","AU","AW","AX","AZ","BA","BB","BD","BE","BF","BG","BH","BI","BIZ","BJ","BM","BN","BO","BR","BS","BT","BV","BW","BY","BZ","CA","CAT","CC","CD","CF","CG","CH","CI","CK","CL","CM","CN","CO","COM","COOP","CR","CU","CV","CW","CX","CY","CZ","DE","DJ","DK","DM","DO","DZ","EC","EDU","EE","EG","ER","ES","ET","EU","FI","FJ","FK","FM","FO","FR","GA","GB","GD","GE","GF","GG","GH","GI","GL","GM","GN","GOV","GP","GQ","GR","GS","GT","GU","GW","GY","HK","HM","HN","HR","HT","HU","ID","IE","IL","IM","IN","INFO","INT","IO","IQ","IR","IS","IT","JE","JM","JO","JOBS","JP","KE","KG","KH","KI","KM","KN","KP","KR","KW","KY","KZ","LA","LB","LC","LI","LK","LR","LS","LT","LU","LV","LY","MA","MC","MD","ME","MG","MH","MIL","MK","ML","MM","MN","MO","MOBI","MP","MQ","MR","MS","MT","MU","MUSEUM","MV","MW","MX","MY","MZ","NA","NAME","NC","NE","NET","NF","NG","NI","NL","NO","NP","NR","NU","NZ","OM","ORG","PA","PE","PF","PG","PH","PK","PL","PM","PN","POST","PR","PRO","PS","PT","PW","PY","QA","RE","RO","RS","RU","RW","SA","SB","SC","SD","SE","SG","SH","SI","SJ","SK","SL","SM","SN","SO","SR","ST","SU","SV","SX","SY","SZ","TC","TD","TEL","TF","TG","TH","TJ","TK","TL","TM","TN","TO","TP","TR","TRAVEL","TT","TV","TW","TZ","UA","UG","UK","US","UY","UZ","VA","VC","VE","VG","VI","VN","VU","WF","WS","YE","YT","ZA","ZM","ZW"
        };

        private string PASSWORD_CHARS_LCASE = "abcdefgijkmnopqrstwxyz";
        private string PASSWORD_CHARS_NUMERIC = "23456789";

        protected override void OnGenerateNextValues()
        {
            Generate();
        }

        private string PickExtension()
        {
            int num = new Random().Next(0, validExtensions.Count() - 1);
            return validExtensions[num].ToLower();
        }

        private string PickLetter()
        {
            int num = new Random().Next(0, PASSWORD_CHARS_LCASE.Length-1); 
            return PASSWORD_CHARS_LCASE[num].ToString();
            
        }

        private string PickChar()
        {
            String numsAndChars = String.Concat(PASSWORD_CHARS_LCASE, PASSWORD_CHARS_NUMERIC);
            int num = new Random().Next(0, numsAndChars.Length-1);
            return numsAndChars[num].ToString();
        }

        public void Generate()
        {
            //username: xxxx.yyy of xxxx_yyyy of xxxxyyy of xxx-yyyy
            //domainname: XXXX.ext
            //valid exts in list
            StringBuilder sb = new StringBuilder();
            sb.Append(PickLetter());
            for (int i = 0; i < new Random().Next(0, 11); i++)
            {
                sb.Append(PickChar());
                System.Threading.Thread.Sleep(1);
            }
            sb.Append("@");
            for (int i = 0; i < new Random().Next(1, 24); i++)
            {
                sb.Append(PickLetter());
                System.Threading.Thread.Sleep(1);
            }
            sb.Append(".");
            sb.Append(PickExtension());
            _output = sb.ToString();
        }
    }
}
