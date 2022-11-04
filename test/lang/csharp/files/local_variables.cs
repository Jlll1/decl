namespace LocalVars;

public class LocalVariables
{
  public void Faffafa()
  {
    var aaa = 1;
    var yyy = 2;
  }

  public void Akajfhajhs()
  {
    var aaa = 5;
    var ccc = aaa + 1;

    {
      var yyy = 10;
      var ddd = aaa + yyy;
    }

    var yyy = 20;
    var zzz = aaa + yyy;
  }

  public void Zzzzzzzz()
  {
    void Abc()
    {
      var x = 5;
    }

    Abc();

    {
      Abc();

      void Def()
      {
        var z = 1;
      }
      Def();
    }

    void Def()
    {
      var z = 1;
    }
    Def();
  }
}
