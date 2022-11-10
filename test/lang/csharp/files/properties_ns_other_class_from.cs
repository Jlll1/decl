using PropertiesNSTo;

namespace PropertiesNS;

public class PropertiesOtherClassFrom
{
  public string SomePropOtherClassNS { get; set; }

  public int SomeMethodOtherClassNS()
  {
  }

  public void Test()
  {
    var x = new PropertiesOtherClassFrom();
    Something(x.SomePropOtherClassNS);
    var a = x.SomePropOtherClassNS;
    var b = x.SomeMethodOtherClassNS();
    x.SomePropOtherClassNS;
    x.SomeMethodOtherClassNS();
  }
}
