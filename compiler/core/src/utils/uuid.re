let currentUUIDCount = ref(1);

let next = (): string => {
  let currentCount = currentUUIDCount^;
  currentUUIDCount := currentCount + 1;
  string_of_int(currentCount);
};