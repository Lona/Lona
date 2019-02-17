import { assert } from 'chai';
import sinon from 'sinon';

import airbnb from '../src';

describe('A test', () => {
  it('should work', () => {
    assert(airbnb() === 'Airbnb', 'works');
  });

  it('should spy', () => {
    const spy = sinon.spy();
    spy();
    assert(spy.calledOnce, 'was called');
  });
});
