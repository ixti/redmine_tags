describe('the truth', function () {
  it('is true', function () {
    expect(truth()).to.equal(true);
  });

  it('fails', function () {
    expect(truth()).to.equal(false);
  });
});
