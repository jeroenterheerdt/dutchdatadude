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
    public class LoremIpsumGenerator: Generator
    {
        private MyLoremIpsumArray _myList;
        private string _output;
        [Output(Description = " Default output ", Name = " Default output ")]
        public string Output
        {
            get { return _output; }
        }

        [Input(Description="The number of words to generate",Name="Number of words")]
        public int NumberOfWords
        {
            set { _numberOfWords = value;}
            get { return _numberOfWords;}
        }

        [Input(Description = "Start with Lorem Ipsum?", Name = "Start with Lorem Ipsum")]
        public bool StartWithLoremIpsum
        {
            set { _startwithLoremIpsum = value; }
            get { return _startwithLoremIpsum; }
        }

        [Input(Description = "Choose random words (true) or follow sentences (false)", Name = "Choose random words")]
        public bool ChooseRandomWords
        {
            set { _chooseRandomWords = value; }
            get { return _chooseRandomWords; }
        }

        private int _numberOfWords = 50;
        private bool _startwithLoremIpsum = true;
        private bool _chooseRandomWords = false;

        public LoremIpsumGenerator()
        {
            _myList = new MyLoremIpsumArray();
        }
        protected override void OnGenerateNextValues()
        {
            Generate();
        }

        public void Generate()
        {
            StringBuilder sb = new StringBuilder();
            if (_chooseRandomWords)
            {
                for (int i = 0; i < NumberOfWords; i++)
                {
                    sb.Append(_myList.getRandom() + " ");
                }
                _output = sb.ToString();
                
            }
            else
            {
                _output = _myList.GetText(NumberOfWords, StartWithLoremIpsum);
            }
            _output = char.ToUpper(_output[0]) + _output.Substring(1);
        }
        

    }

    public class MyLoremIpsumArray
    {
        private string loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse tempor interdum sem, sed euismod tellus blandit vel. Aliquam erat volutpat. Aenean erat augue, rhoncus ac leo at, molestie eleifend erat. Aenean sed tellus id ipsum malesuada tempor ut sit amet lectus. Vivamus tristique mi leo, pretium sagittis justo congue id. Donec in vehicula elit. Mauris posuere scelerisque lobortis. Fusce accumsan justo arcu, in varius erat semper nec. Pellentesque ut arcu ut sem pulvinar posuere. In rhoncus odio magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Proin volutpat nisl id urna commodo, vel posuere dui adipiscing. Suspendisse nec lacus quis turpis consectetur convallis. In nec laoreet sem, a sagittis massa. Vivamus sodales accumsan ligula. Donec mattis dictum diam, sit amet malesuada felis. Integer pretium sollicitudin erat id mollis. Sed consequat neque vel velit dictum, tempus mattis lectus dapibus. Nulla varius libero libero, nec iaculis nibh luctus sed. Morbi et mauris et eros bibendum consequat non eu nisl. Nunc sed tincidunt sem. Suspendisse ac vestibulum leo. Vivamus eu massa ornare, vestibulum ipsum ut, imperdiet ligula. Donec dignissim, nibh vitae fermentum lobortis, dui elit consectetur justo, sed sodales eros mi a purus. Nulla facilisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Aliquam vel ipsum ut tortor ultricies consequat sed eget nisi. Suspendisse ac sapien at eros lobortis faucibus. Suspendisse at libero cursus odio vulputate fringilla vitae in velit. In dignissim, nunc vitae malesuada lobortis, ligula justo fermentum ligula, in dignissim turpis enim eget metus. Interdum et malesuada fames ac ante ipsum primis in faucibus. Vestibulum vel elit justo. Vestibulum nulla dolor, aliquet eget tempor id, gravida id dui. Donec felis tellus, tempus eget purus convallis, interdum adipiscing ligula. Maecenas malesuada tristique fermentum. Maecenas nec nisi sem. Mauris sem justo, sollicitudin non convallis vel, interdum tincidunt ligula. Fusce iaculis urna nec metus vulputate, viverra interdum quam molestie. Donec pulvinar id nunc ac eleifend. Proin euismod odio odio. Nullam leo metus, venenatis a purus nec, gravida vulputate est. Nunc rutrum eu augue vitae vehicula. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Mauris eget cursus elit. Ut id rhoncus arcu. Sed eu augue lacus. Nam sed vestibulum quam. Duis vel tincidunt mauris, vitae pretium nulla. Nam ligula ipsum, malesuada tincidunt arcu at, tincidunt consequat odio. Vivamus dictum lobortis dapibus. Morbi ullamcorper mauris nisl. Vivamus aliquet ligula metus, vel ultrices arcu porttitor facilisis. Ut mollis diam quam. Praesent elementum luctus sapien, sed tempus elit dignissim sed. Aenean interdum quam a erat aliquet pulvinar. Proin id erat ut nulla bibendum varius. Maecenas aliquam sem vitae mauris malesuada, sollicitudin ornare erat euismod. Pellentesque blandit erat ante, vel sodales leo vulputate sed. Ut scelerisque massa quis nulla consectetur adipiscing. Integer nec felis ultrices, ullamcorper mi quis, congue mi. Ut velit augue, sollicitudin a nisl eu, rutrum convallis dui. Vestibulum auctor ornare magna. Integer a nisl odio. Vivamus sit amet lacus id massa porta venenatis a at dolor. Mauris a mauris sodales ligula consequat cursus. Vivamus id mauris quam. In in tincidunt massa, in mollis quam. Suspendisse feugiat, ante eu porta pulvinar, dolor mi malesuada purus, a consectetur neque eros in diam. Donec laoreet ornare mauris, sed fringilla felis faucibus ut. Etiam sit amet purus quis libero sodales ultrices. Phasellus malesuada, diam consectetur porttitor condimentum, velit ipsum eleifend tortor, nec consectetur erat dolor vel ante. Cras eget volutpat odio, et dapibus tellus. Nulla sodales, eros sit amet blandit posuere, mi ligula eleifend ipsum, eu fringilla orci lacus eget ante. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In blandit quam et lectus vulputate commodo. Vivamus molestie sed magna ac pharetra. Curabitur ligula odio, malesuada quis nunc et, eleifend pellentesque sapien. Aliquam fringilla lorem eu pellentesque pharetra. In ullamcorper quis eros et gravida. Aenean sit amet viverra urna. Nam vitae mauris eu urna dignissim volutpat. Quisque luctus orci odio, sit amet elementum lectus ultricies et. In hac habitasse platea dictumst. In consectetur mi ac nibh faucibus consequat. Maecenas pulvinar condimentum enim, in feugiat ante scelerisque nec. Donec consectetur faucibus sapien, et congue dui dignissim vitae. Nullam quis risus non quam commodo tincidunt. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Curabitur risus tortor, molestie eget facilisis at, eleifend ac nunc. Aliquam gravida, elit eget iaculis mollis, sapien libero tempor ipsum, vitae placerat nulla augue ut nisl. Mauris facilisis lacus velit, mollis gravida ipsum pretium vel. Mauris auctor commodo turpis, in malesuada ligula. Integer rutrum sem nisi, vel pretium justo consequat nec. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nam lobortis magna vel eleifend tempus. Donec magna justo, condimentum cursus aliquam cursus, aliquam et justo. Donec sit amet fermentum nunc, eget feugiat dolor. Fusce nec nunc rhoncus, pellentesque quam et, lobortis nulla. In consequat ut purus in faucibus. Aenean aliquam sagittis lectus non pretium. Duis luctus varius placerat. Fusce arcu neque, ornare in ligula vel, vestibulum bibendum dolor. Aenean massa leo, venenatis ac porta sit amet, feugiat id magna. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut rhoncus elementum diam, sed tincidunt urna molestie id. Vivamus quis felis pellentesque, eleifend quam eu, varius lacus. Proin sodales velit leo, ut iaculis massa mattis sed. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In sed elit ultricies, pharetra lectus vel, lacinia quam. Ut et nulla ut urna rutrum imperdiet. Sed mollis lacinia justo, et egestas sapien congue sit amet. Mauris congue purus et ligula mollis, vitae mollis arcu convallis. Morbi in leo vitae mauris lacinia bibendum vitae sit amet sapien. Etiam bibendum dapibus sem. Fusce aliquet adipiscing rutrum. Vivamus in nibh purus. Donec hendrerit odio vitae neque hendrerit gravida. Suspendisse potenti. Aenean id augue consectetur, sodales orci ut, convallis lorem. Curabitur at tellus rutrum, porta erat in, scelerisque ipsum. Pellentesque convallis mauris vel magna sodales euismod. Proin scelerisque et odio eget mattis. Donec sollicitudin egestas odio at volutpat. In et lobortis lectus. Duis in facilisis massa. Quisque nec scelerisque tortor. Ut et massa lobortis, pretium est sit amet, rutrum eros. In at scelerisque arcu, nec aliquam nisl. Nunc tellus turpis, sodales tempor blandit at, hendrerit sit amet purus. Vivamus vehicula nibh ac venenatis sodales. Phasellus gravida, elit sed bibendum luctus, ipsum lorem condimentum quam, ut laoreet mi elit a eros. Aliquam elementum, dui eu auctor euismod, ante est scelerisque ligula, consequat pretium turpis tortor non neque. Cras eget egestas velit, feugiat dignissim lacus. Nam id elit vitae ante tristique ultrices id non est. Duis erat tellus, lobortis quis aliquet vitae, vulputate at justo. Integer vitae rutrum lorem. Cras blandit dolor vel ipsum lacinia, eleifend placerat leo sodales. Ut vel consectetur purus. Aenean ac interdum est. Donec facilisis tortor mi, at rutrum lorem ornare ac. In elementum felis vel quam consequat tincidunt. Morbi tincidunt diam vitae magna imperdiet mollis. Etiam ultricies feugiat vestibulum. Nam vehicula est eget tortor lacinia condimentum. Quisque at sem ac lorem gravida sollicitudin. Nullam eu pellentesque neque. Integer sed ante non felis feugiat porttitor. Nam ac congue diam. Nam risus nunc, dapibus ut sodales nec, viverra nec odio. Integer blandit turpis eu elit lobortis, ut volutpat ipsum ornare. In hac habitasse platea dictumst. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce pharetra nisi nulla, at accumsan libero lobortis quis. Morbi quis quam eu lectus cursus imperdiet vel nec felis. Vivamus dolor massa, vestibulum et sem eu, imperdiet mollis est. Praesent sed vehicula magna. Mauris cursus turpis ut risus pretium dictum. Nullam orci ipsum, facilisis ac dolor convallis, imperdiet convallis lorem. Praesent eu tempus sapien, eget eleifend magna. Quisque nec leo non orci fringilla rhoncus. Maecenas ipsum urna, lobortis vel iaculis ut, fringilla nec arcu. Proin sollicitudin purus aliquam ligula euismod egestas. Mauris placerat nisl diam, a tincidunt tortor aliquet quis. Phasellus aliquet ligula et felis bibendum tincidunt. Cras aliquam velit eget ipsum malesuada elementum. Maecenas nibh ante, vehicula in blandit ut, lobortis eu nisl. Donec sed purus a leo malesuada pharetra. Integer consequat, tortor vulputate adipiscing venenatis, lorem neque sollicitudin lorem, non facilisis sapien orci at purus. Quisque laoreet neque felis, ac vehicula ipsum congue sit amet. Maecenas venenatis purus mattis turpis pharetra, at suscipit urna ultricies. Nulla lorem dui, pulvinar sit amet enim vel, hendrerit convallis turpis. Praesent dictum eros velit, vel placerat justo tempor nec. Aliquam erat volutpat. Cras ac ipsum vitae massa consequat euismod et ut risus. Mauris congue nibh et sapien mollis vestibulum. Morbi id lacus eu arcu tincidunt bibendum. Aliquam erat volutpat. Nunc vitae metus vehicula, tempor urna quis, consectetur nunc. Nulla fringilla porta arcu, eget adipiscing lacus fermentum gravida. Cras vulputate elit urna, id condimentum augue malesuada ut. Suspendisse ut enim dapibus, gravida justo sit amet, ultrices nisl. In ut augue luctus, pellentesque odio et, pellentesque justo. Vestibulum lorem metus, congue sed ipsum sit amet, condimentum congue turpis. Sed tincidunt suscipit imperdiet. Suspendisse mauris sem, hendrerit vel enim sed, congue blandit libero. Aliquam scelerisque nisl vel ultrices pretium. Morbi sed vestibulum lectus, et tincidunt massa. Proin vitae sem venenatis, tristique nunc ut, dignissim sem. Vestibulum ultricies nisl et vehicula molestie. Suspendisse eu lorem lacinia, rhoncus libero vitae, consectetur tortor. Fusce consequat eros dui. Donec at mattis est, in euismod leo. Aenean vitae velit vulputate, consequat turpis sed, scelerisque massa. Etiam commodo eros purus, sit amet euismod neque fringilla in. Etiam a vestibulum leo. Donec ante nulla, facilisis blandit tincidunt aliquet, lacinia non justo. Quisque et enim ut mauris ullamcorper dictum at sit amet nulla. Quisque eu enim mauris. Sed pretium dolor pharetra ornare suscipit. Ut eget lectus quis nisl porta faucibus nec eget turpis. Maecenas rutrum urna nisi, sit amet volutpat tortor adipiscing at. Nunc eget mi in purus posuere pulvinar. Proin porta ut lectus vel condimentum. Morbi id vulputate neque, sit amet interdum nunc. Donec elementum et leo in feugiat. Duis sed malesuada lectus. Ut ac suscipit est.";
        private string[] loremIpsumList;

        public MyLoremIpsumArray()
        {
            loremIpsum = loremIpsum.Replace(",", "");
            loremIpsum = loremIpsum.Replace(".", "");
            loremIpsum = loremIpsum.ToLower();
            loremIpsumList = loremIpsum.Split(' ');
        }

        public string getRandom()
        {
            System.Threading.Thread.Sleep(1);
            return loremIpsumList.NextRandom();
        }


        internal string GetText(int NumberOfWords, bool StartWithLoremIpsum)
        {
            if (StartWithLoremIpsum)
            {
                return String.Join(" ", loremIpsumList.Take(NumberOfWords).ToArray());
                
            }
            else
            {
                Random gen = new Random();
                return loremIpsumList.Skip(gen.Next(0, loremIpsumList.Count() - 1) - 1).Take(NumberOfWords).ToArray()[0];
            }
        }
    }

    public static class MyExtensionMethod
    {
        public static T NextRandom<T>(this IEnumerable<T> source)
        {
            Random gen = new Random();
            return source.Skip(gen.Next(0, source.Count() - 1) - 1).Take(1).ToArray()[0];
        }
    }
}
