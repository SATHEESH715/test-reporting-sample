namespace SampleApi.Tests;

[TestClass]
public class TenancyDataTests
{
    [TestMethod]
    public void GetAll_ReturnsThreeTenancies() =>
        Assert.AreEqual(3, TenancyData.GetAll().Count);

    [TestMethod]
    public void GetAll_HasUniqueTenancyNumbers() =>
        Assert.AreEqual(3, TenancyData.GetAll().Select(t => t.TenancyNumber).Distinct().Count());

    [TestMethod]
    public void GetAll_ContainsAnEndedTenancy() =>
        Assert.IsTrue(TenancyData.GetAll().Any(t => t.Status == "Ended"));
}
