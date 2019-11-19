export type Preset = { name: string; width: number; height: number }
export type Device =
  | {
      deviceId: string
      name?: string
      width?: number
    }
  | {
      deviceId?: string
      name: string
      width: number
    }

export default function deviceInfo(device: Device, devicePresetList: Preset[]) {
  if (device.deviceId) {
    const preset = devicePresetList.find(x => x.name === device.deviceId)
    if (!preset) {
      if (device.name && device.width) {
        return { name: device.name, width: device.width }
      }
      throw new Error(`Couldn't find the preset ${device.deviceId}`)
    }
    return { name: preset.name, width: preset.width }
  }
  return { name: device.name, width: device.width }
}
