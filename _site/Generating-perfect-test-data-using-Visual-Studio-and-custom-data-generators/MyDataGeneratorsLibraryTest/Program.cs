using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MyDataGeneratorsLibrary;

namespace MyDataGeneratorsLibraryTest
{
    class Program
    {
        static void Main(string[] args)
        {
            LoremIpsumGenerator lig = new LoremIpsumGenerator();
            lig.Generate();

            EmailAddressGenerator eag = new EmailAddressGenerator();
            eag.Generate();
        }
    }
}
