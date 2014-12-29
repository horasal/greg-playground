import structs/ArrayList

Tree: class {
    rules: ArrayList<Rule> = ArrayList<Rule> new()
    actions: ArrayList<Action> = ArrayList<Action> new()
    currentRule: Rule
    start: Node

    lastToken: Int

    init: func

    compile: func{
        for(r in rules){ r cosumeInput() }

    }

    findRule: func(name: String, defined: Bool) -> Rule{
        i: Int = 0
        while(i < name length){
            if(name[i] <= 128){
                if(name[i] == '-') name[i] = '_'
            } else {
                i += 1
            }
            i += 1
        }

        for(rule in rules){
            if(rule name == name) return rule
        }

        rules add(Rule new(name, rules size, defined))
        return rules last()
    }

    addAction: func(text: String){
        if(!current){ Exception new("No current rule!") throw() }
        action := Action new(text, currentRule)
        actions add(action)
    }

    beginRule: func(rule: Rule) -> Rule{
        currentRule = rule
        currentRule
    }

    beginRule: func ~index (idx: Int) -> Rule{
        currentRule = rules[idx]
        currentRule
    }

    setExpression: func(rule: Rule, exp: Node){
        rule expression = exp
        if(!start || rule name == "start"){
            start = rule
        }
    }
}

RuleFlag: enum{
    Unuse = 0,
    Used = 1 << 0,
    Reached = 1<<1
}

Node: class {
    errblock: String

    consumeInput: func -> Int{
        match(this){
            case rule: Rule = > 
                result := 0
                if(RuleFlag Reached & rule flags){
                    Exception new("possible infinite left recursion in rule \"%s\"" format(rule name))
                } else {
                    rule flags |= RuleFlag Reached as Int
                    if(rule expression) result = rule expression consumeInput()
                    rule flags &= ~(RuleFlag Rearched as Int)
                }
                return result;
            case dot: Dot => return 1
            case name: Name => return consumeInput(name rule)
            case c: Character => return c value length > 0
            case str: _String => return str value length > 0
            case c: _Class => return 1
            case a: Action => return 0
            case p: Predicate => return 0
            case a: Altername => 
                for(sa in a node){
                    if(!sa consumeInput()){ return 0 }
                }
                return 1
            case s: Sequence => 
                for(ss in s node){
                    if(ss consumeInput()){ return 1 }
                }
                return 0
            case p: PeekFor => return 0
            case p: PeekNot => return 0
            case q: Query => return 0
            case s: Star => return 0
            case p: Plus => return p element consumeInput()
            case => Exception new("Unknown node type") throw()
        }
        return 0
    }
}

Rule: class extends Node{
    name: String
    variables: ArrayList<Node>
    expression: Node
    id: Int
    flags: Int 

    init: func(=name, =id, defined: Bool){
        flags = (defined ? RuleFlag Used : RuleFlag Unuse) as Int
    }

    makeName: func {
        name = Name new(this, null)
        flags |= RuleFlag Used as Int
    }
}

Variable: class extends Node {
    name: String
    value: Node
    offset: Int

    init: func
}

Name: class extends Node{
    rule: Node
    variable: Node

    init: func(=rule, =variable)
}

Dot: class extends Node{
    init: func
}

Character: class extends Node{
    value: String

    init: func(=value)
}

// String is a reversed word of ooc
_String: class extends Node{
    value: String

    init: func(=value)
}

_Class: class extends Node{
    value: String

    init: func(=value)
}

Action: class extends Node{
    text: String
    name: String
    rule: Node

    init: func(=name, =rule){
        text = name clone()

        i := 0
        while(i < text length - 1){
            if(text[i] == '$' &&  text[i+1] == '$'){
                text[i] = 'y'
                text[i+1] = 'y'
            }
        }
    }
}

Predicate: class extends Node{
    text: String

    init: func(=text)
}

Alternate: class extends Node {
    node: ArrayList<Node> = ArrayList<Node> new()

    init: func

    append: func(e: Node){
        node add(e)
    }
}

Sequence: class extends Node {
    node: ArrayList<Node> = ArrayList<Node> new()

    init: func
    
    append: func(e: Node){
        node add(e)
    }
}

PeekFor: class extends Node {
    element: Node
    init: func(=element)
}

PeekNot: class extends Node{
    element: Node
    init: func(=element)
}

Query: class extends Node{
    element: Node
    init: func(=element)
}

Star: class extends Node{
    element: Node
    init: func(=element)
}

Plus: class extends Node{
    element: Node
    init: func(=element)
}

Any: class extends Node{
    element: Node
    init: func(=element)
}
