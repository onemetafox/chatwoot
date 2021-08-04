import MessageFormatter from '../MessageFormatter';

describe('#MessageFormatter', () => {
  describe('content with links', () => {
    it('should format correctly', () => {
      const message =
        'Abrand is an opensource tool. [Abrand](https://www.chatwoot.com)';
      expect(new MessageFormatter(message).formattedMessage).toMatch(
        '<p>Abrand is an opensource tool. <a rel="noreferrer noopener nofollow" href="https://www.chatwoot.com" class="link" title="" target="_blank">Abrand</a></p>'
      );
    });
    it('should format correctly', () => {
      const message =
        'Abrand is an opensource tool. https://www.chatwoot.com';
      expect(new MessageFormatter(message).formattedMessage).toMatch(
        '<p>Abrand is an opensource tool. <a rel="noreferrer noopener nofollow" href="https://www.chatwoot.com" class="link" title="" target="_blank">https://www.chatwoot.com</a></p>'
      );
    });
  });

  describe('parses heading to strong', () => {
    it('should format correctly', () => {
      const message = '### opensource \n ## tool';
      expect(new MessageFormatter(message).formattedMessage).toMatch(
        '<strong>opensource</strong><strong>tool</strong>'
      );
    });
  });

  describe('tweets', () => {
    it('should return the same string if not tags or @mentions', () => {
      const message = 'Abrand is an opensource tool';
      expect(new MessageFormatter(message).formattedMessage).toMatch(message);
    });

    it('should add links to @mentions', () => {
      const message =
        '@chatwootapp is an opensource tool thanks @longnonexistenttwitterusername';
      expect(new MessageFormatter(message, true).formattedMessage).toMatch(
        '<p><a href="http://twitter.com/chatwootapp" target="_blank" rel="noreferrer nofollow noopener">@chatwootapp</a> is an opensource tool thanks @longnonexistenttwitterusername</p>'
      );
    });

    it('should add links to #tags', () => {
      const message = '#chatwootapp is an opensource tool';
      expect(new MessageFormatter(message, true).formattedMessage).toMatch(
        '<p><a href="https://twitter.com/hashtag/chatwootapp" target="_blank" rel="noreferrer nofollow noopener">#chatwootapp</a> is an opensource tool</p>'
      );
    });
  });

  describe('plain text content', () => {
    it('returns the plain text without HTML', () => {
      const message =
        '<b>Abrand is an opensource tool. https://www.chatwoot.com</b>';
      expect(new MessageFormatter(message).plainText).toMatch(
        'Abrand is an opensource tool. https://www.chatwoot.com'
      );
    });
  });
});
