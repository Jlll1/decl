using PropertiesNSTo;

namespace PropertiesNS;

public class PropertiesOtherClassFrom
{
  public string SomeProp { get; set; }

  public int SomeMethod()
  {
  }

  public void Test()
  {
    var x = new PropertiesOtherClassFrom();
    Something(x.SomeProp);
    var a = x.SomeProp;
    var b = x.SomeMethod();
    x.SomeProp;
    x.SomeMethod();
  }
}
