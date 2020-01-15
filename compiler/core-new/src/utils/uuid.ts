let currentUUIDCount = 1

export default () => {
  let currentCount = currentUUIDCount
  currentUUIDCount = currentCount + 1
  return currentCount.toString()
}
