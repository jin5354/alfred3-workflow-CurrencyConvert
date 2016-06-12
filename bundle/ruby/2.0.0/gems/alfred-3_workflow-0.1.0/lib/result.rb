class Result

  def initialize
    @arg = nil
    @autocomplete = nil
    @icon = nil
    @mods = {}
    @quicklookurl = nil
    @subtitle = nil
    @text = {}
    @title = nil
    @type = nil
    @uid = nil
    @valid = true

    @simple_values = [
      'arg',
      'autocomplete',
      'quicklookurl',
      'subtitle',
      'title',
      'uid',
    ]

    @valid_values = {
      type: ['default', 'file', 'file:skipcheck'],
      icon: ['fileicon', 'filetype'],
      text: ['copy', 'largetype'],
      mod: ['shift', 'fn', 'ctrl', 'alt', 'cmd']
    }
  end

  public
  def valid(valid)
    @valid = !!valid
    self
  end

  public
  def type(type, verify_existence = true)
    return self unless @valid_values[:type].include?(type.to_s)

    if type === 'file' && !verify_existence
      @type = 'file:skipcheck'
    else
      @type = type
    end

    self
  end

  public
  def icon(path, type = nil)
    @icon = {
      path: path
    }

    @icon[:type] = type if @valid_values[:icon].include?(type.to_s)

    self
  end

  public
  def fileicon_icon(path)
    icon(path, 'fileicon')
  end

  public
  def filetype_icon(path)
    icon(path, 'filetype')
  end

  public
  def text(type, text)
    return self unless @valid_values[:text].include?(type.to_s)

    @text[type.to_sym] = text

    self
  end

  public
  def mod(mod, subtitle, arg, valid = true)
    return self unless @valid_values[:mod].include?(mod.to_s)

    @mods[mod.to_sym] = {
      subtitle: subtitle,
      arg: arg,
      valid: valid
    }

    self
  end

  public
  def to_hash
    keys = [
      'arg',
      'autocomplete',
      'icon',
      'mods',
      'quicklookurl',
      'subtitle',
      'text',
      'title',
      'type',
      'uid',
      'valid',
    ]

    result = {}

    keys.each { |key|
      result[key.to_sym] = self.instance_variable_get("@#{key}")
    }

    result.select { |hash_key, hash_value|
      (hash_value.class.to_s === 'Hash' && !hash_value.empty?) || (hash_value.class.to_s != 'Hash' && !hash_value.nil?)
    }
  end

  def method_missing(method, *arguments)
    if @simple_values.include?(method.to_s)
      self.instance_variable_set("@#{method}", arguments.first)
      return self
    end

    if @valid_values[:mod].include?(method.to_s)
      return mod(method, *arguments)
    end

    if @valid_values[:text].include?(method.to_s)
      return text(method, *arguments)
    end

    super
  end

  def respond_to?(method, include_private = false)
    if @simple_values.include?(method.to_s)
      return true
    end

    if @valid_values[:mod].include?(method.to_s)
      return true
    end

    if @valid_values[:text].include?(method.to_s)
      return true
    end

    super
  end

end
