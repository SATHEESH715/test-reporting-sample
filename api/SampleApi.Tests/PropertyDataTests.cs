namespace SampleApi.Tests;

[TestClass]
public class PropertyDataTests
{
    [TestMethod]
    public void GetAll_ReturnsThreeProperties() =>
        Assert.AreEqual(3, PropertyData.GetAll().Count);

    [TestMethod]
    public void GetAll_HasUniquePropertyNumbers() =>
        Assert.AreEqual(3, PropertyData.GetAll().Select(p => p.PropertyNumber).Distinct().Count());

    [TestMethod]
    public void GetAll_ContainsAVoidProperty() =>
        Assert.IsTrue(PropertyData.GetAll().Any(p => p.Status == "Void"));
}
