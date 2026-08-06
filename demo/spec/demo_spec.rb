require "pg"

RSpec.describe "Environment Contract" do
  it "uses Ruby 4.0" do
    expect(RUBY_VERSION).to start_with("4.0.")
  end

  it "loads PostgreSQL C-library (libpq)" do
    expect(PG.library_version).to be > 0
  end
end
