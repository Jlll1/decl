using PropertiesNSTo;

namespace PropertiesNS;

public class PropertiesOtherClassFrom
{
  public string SomePropOtherClass { get; set; }

  public int SomeMethodOtherClass()
  {
  }

  public void Test()
  {
    var x = new PropertiesOtherClassFrom();
    Something(x.SomePropOtherClass);
    var a = x.SomePropOtherClass;
    var b = x.SomeMethodOtherClass();
    x.SomePropOtherClass;
    x.SomeMethodOtherClass();
  }
}
