import { checkEyes, environment } from "../../utils";
describe("Visual Regression Testing", () => {
  before(() => {
    cy.eyesOpen({
      appName: "Lona",
      testName: "home page",
      browser: environment
    });
  });
  after(() => {
    cy.eyesClose();
  });
  it("check home page", () => {
    cy.visit("/");
    checkEyes("home page");
  });
  it("check home page selected", () => {
    cy.visit("/");
    cy.get("[role=checkbox] :first-child").each((el, index) => {
      if (index === 0) {
        cy.wrap(el).click();
      }
    });
    checkEyes("home page selected");
  });
});
