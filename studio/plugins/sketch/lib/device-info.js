module.exports = function deviceInfo(device, devicePresetList) {
  if (device.deviceId) {
    const preset = devicePresetList.find(
      preset => preset.name === device.deviceId
    );
    return { name: preset.name, width: preset.width };
  } else {
    return { name: device.name, width: device.width };
  }
};
