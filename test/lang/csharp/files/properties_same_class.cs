namespace Properties;

public class PropertiesSameClass
{
  public string SomeProp { get; set; }

  public int SomeMethod()
  {
  }

  public void Test()
  {
    Something(SomeProp);
    var x = SomeProp;
    var a = SomeMethod();
    SomeProp;
    SomeMethod();
  }
}
