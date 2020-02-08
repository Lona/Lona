import isEqual from 'lodash.isequal'

export class ShallowMap<K, T> {
  public map: { key: K; value: T }[] = []

  private find(k: K) {
    return (x: { key: K; value: T }) => isEqual(x.key, k)
  }

  public get(k: K): T | undefined {
    const found = this.map.find(this.find(k))
    if (found) {
      return found.value
    }
  }

  public set(k: K, v: T) {
    const existing = this.map.findIndex(this.find(k))
    if (existing !== -1) {
      this.map[existing].value = v
    } else {
      this.map.push({ key: k, value: v })
    }
  }

  public copy() {
    const dup = new ShallowMap<K, T>()
    this.map.forEach(x => dup.set(x.key, x.value))
    return dup
  }

  public isEmpty() {
    return this.map.length === 0
  }
}
