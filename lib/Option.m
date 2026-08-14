classdef Option
    properties
        value
    end
    properties (Access = private)
        contains_val
    end
    methods(Static)
        function none = None()
            none = Option();
        end
        function some = Some(val)
            some = Option(val);
        end
    end
    methods
        function r = is_some(self)
            r = self.contains_val;
        end
        function r = and_then(self, func)
            self = self(~self.is_none);
            if self.is_none
                r = Option.None;
                return
            end
            val = {self.value};
            r = cellfun(func, val, "UniformOutput", false);
            r = r(cellfun(@(x) x.is_some, r));
            if isscalar(r)
                r = r{:};
            end
            if isempty(r)
                r = Option.None();
            end
        end
        function r = expect(self, msg)
            if self.is_none
                error(msg)
            end
            r = {self.value};
            if isscalar(r)
                r = r{:};
            end
        end
        function r = unwrap(self)
            r = self.expect("Called unwrap() on None");
        end
        function r = unwrap_or(self, default)
            r = {self.value};
            is_none = self.is_none();
            [r{is_none}] = deal(default);
            if any(cellfun(@ischar, r))
                return
            end
            r = cell2mat(r);
        end
        function r = is_none(self)
            some = [self.contains_val];
            val = {self.value};
            r = ~some & cellfun(@isempty, val);

            % r = ~self.is_some && isempty(self.value);
        end
        function r = map(self, func)
            self = self(~self.is_none);
            if isempty(self)
                r = Option.None();
                return;
            end
            val = {self.value};
            r = Option(cellfun(func, val, "UniformOutput", false));
            if isscalar(r.value)
                r.value = r.value{:};
            end
            self = r;
        end
        function r = filter(self, predicate)
            keyboard
            self = self(~self.is_none());

            if isempty(self)
                r = Option.None();
                return;
            end

            passes = cellfun(predicate, {self.value}, 'UniformOutput', true);
            self = self(passes);

            if isempty(self)
                r = Option.None();
                return;
            end

            r = self;
        end
        function r = filter_map(self, func)
            self = self(~self.is_none());
            if isempty(self)
                r = Option.None();
                return;
            end

            val = {self.value};

            % Apply func to each value — func returns an Option
            results = cellfun(func, val, "UniformOutput", false);

            % Keep only Some results
            is_some = cellfun(@(x) x.is_some(), results);
            results = results(is_some);

            if isempty(results)
                r = Option.None();
                return;
            end

            % Unwrap the values from the remaining Somes
            r = cellfun(@(x) x.value, results, "UniformOutput", false);

            if isscalar(r)
                r = r{:};
            end

        end
        function self = Option(val)
            if nargin == 0 || isempty(val)
                self.contains_val = false;
                self.value = [];
            else
                self.contains_val = true;
                self.value = val;
            end
        end
        function r = zip(self, other)
            if self.is_none || other.is_none
                r = Option.None();
                return
            end
            r = Option.Some({self.value, other.value});
        end
    end
end
