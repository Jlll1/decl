using TestNSTo;

namespace TestNS;

public class Decls
{
  public FindMeStruct FindMeStruct { get; set; }

  public FindMeClass FindMeClass { get; set; }

  public FindMeEnum FindMeEnum { get; set; }

  public FindMeRecord FindMeRecord { get; set; }

  public FindMeRecordStruct FindMeRecordStruct { get; set; }

  public FindMeGeneric<string> FindMeGeneric { get; set; }

  public void Asdsdsfffff()
  {
    FindMeStruct fms1 = new ();
    FindMeClass fmc1 = new ();
    FindMeEnum fme1 = FindMeEnum.Abc;
    FindMeRecord fmr1 = new ();
    FindMeRecordStruct fmrs1 = new ();
    FindMeGeneric<int> fmg1 = new ();
    var fms2 = new FindMeStruct();
    var fmc2 = new FindMeClass();
    var fmr2 = new FindMeRecord();
    var fmrs2 = new FindMeRecordStruct();
    var fmg2 = new FindMeGeneric<bool>();
  }

  public FindMeStruct ReturnFindMeStruct()
  {
  }

  public FindMeClass ReturnFindMeClass()
  {
  }

  public FindMeEnum ReturnFindMeEnum()
  {
  }

  public FindMeRecord ReturnFindMeRecord()
  {
  }

  public FindMeRecordStruct ReturnFindMeRecordStruct()
  {
  }

  public FindMeGeneric<char> ReturnFindMeGeneric()
  {
  }

  public void FindMeArguments(
      FindMeStruct fms,
      FindMeClass fmc,
      FindMeEnum fme,
      FindMeRecord fmr,
      FindMeRecordStruct fmrs,
      FindMeGeneric<int> fmg)
  {
  }

  public void FindEnumFromDefault(FindMeEnum fme = FindMeEnum.Abc)
  {
  }
}
