export const environment = { width: 1024, height: 768, name: "chrome" };
export function checkEyes(testName) {
  cy.eyesCheckWindow({
    tag: testName,
    sizeMode: "selector", //mode
    selector: ".App"
  });
}
