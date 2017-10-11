module.exports = function countAssignments(j, path) {
  const assignmentCount = {};

  j(path)
    .find(j.AssignmentExpression)
    // Count the number of times we assign to each variable name
    .forEach((assignmentPath) => {
      const left = j(assignmentPath).get('left').get('name').value;

      if (left !== undefined) {
        assignmentCount[left] =
          left in assignmentCount ? assignmentCount[left] + 1 : 1;
      }
    });

  return assignmentCount;
};
