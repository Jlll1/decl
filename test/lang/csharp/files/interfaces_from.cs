namespace Interfaces;

public class InterfacesTest : IFindMe
{
  public IFindMe FindMe { get; set; }

  public void Defedfef()
  {
    IFindMe fm = new SomeImplementer();
  }

  public IFindMe Fooaooaoao(IFindMe fm)
  {
  }
}
