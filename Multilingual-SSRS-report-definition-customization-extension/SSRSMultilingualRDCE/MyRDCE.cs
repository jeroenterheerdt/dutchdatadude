using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using Microsoft.ReportingServices.Interfaces;

namespace SSRSMultilingualRDCE
{
    public class MyRDCE: IReportDefinitionCustomizationExtension
    {
        //List holding all transformations
        private IList<ITransformation> _transformations;

        bool IReportDefinitionCustomizationExtension.ProcessReportDefinition(byte[] reportDefinition, IReportContext reportContext, IUserContext userContext, out byte[] reportDefinitionProcessed, out IEnumerable<RdceCustomizableElementId> customizedElementIds)
        {
            //load report from byte[]
            XmlDocument d = new XmlDocument();
            MemoryStream ms = null;
            using (ms = new MemoryStream(reportDefinition))
            {
                d.Load(ms);
                ms.Position = 0;
            }

            XElement report = XElement.Load(new XmlNodeReader(d));

            //run all transformations
            if (_transformations != null)
            {
                foreach (ITransformation t in _transformations)
                {
                    report = t.Transform(report, reportContext, userContext);
                }
            }

            //convert report to byte[] so it can be returned to SSRS
            System.Text.Encoding enc = new System.Text.UTF8Encoding();
            reportDefinitionProcessed = enc.GetBytes(report.ToString());

            //we have to inform SSRS about what we changed. In this sample we only change the body part of the report.
            //Other values are: DataSets, Page, PageHeader, PageFooter
            List<RdceCustomizableElementId> ids = new List<RdceCustomizableElementId>();
            customizedElementIds = new List<RdceCustomizableElementId>();
            (customizedElementIds as List<RdceCustomizableElementId>).Add(RdceCustomizableElementId.Body);
            
            return true;
        }

        string IExtension.LocalizedName
        {
            get { return "SSRSMultilingualRDCE"; }
        }

        void IExtension.SetConfiguration(string configuration)
        {
            if (string.IsNullOrEmpty(configuration))
            {
                return;
            }

            _transformations = new List<ITransformation>();

            //load the configuration
            XElement config = XElement.Parse(configuration);
            //retrieve the transformations
            if (config.Name.LocalName == "Transformations")
            {
                //get the transformations
                var trans = from transformation in config.Descendants("Transformation")
                            select new
                            {
                                Name = transformation.Attribute("Name").Value,
                                Transformator = transformation.Attribute("Type").Value.Split(',')[0],
                                CodeBase = transformation.Attribute("Type").Value.Split(',')[1],
                                Properties = transformation.Descendants("Property")
                            };

                //lets add a transformation step for each transformation found
                foreach (var t in trans)
                {
                    ITransformation transformation = (Activator.CreateInstance(t.CodeBase, t.Transformator).Unwrap() as ITransformation);
                    //if we specified additional properties, set them now
                    if(t.Properties!=null) {
                        foreach(var p in t.Properties) {
                            string propName = p.Attribute("Name").Value;
                            string propValue = p.Attribute("Value").Value;
                            PropertyInfo propertyInfo = transformation.GetType().GetProperty(propName);
                            if(propertyInfo!=null) {
                                propertyInfo.SetValue(transformation, propValue,null);
                            }
                        }
                        //add the transformer to the list
                        _transformations.Add(transformation);
                    }
                }
            }
        }
    }
}
