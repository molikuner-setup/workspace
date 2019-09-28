// unterrichts planung

class Block {
    constructor(name, count, ...blockedBlocks) {
        this.name = name
        this.count = count
        this.blockedBlocks = blockedBlocks
    }

    init(blocks) {
        this.blockedBlocks = this.blockedBlocks.map(blockedName => {
            const blockedBlock = blocks.find(block => block.name == blockedName)
            if (!blockedBlock) throw Error(`Could not find ${blockedName} in given blocks, please add missing blocks`)
            return blockedBlock
        })
    }
}

const blocks = [
    new Block('IF1', 5, 'IF2', 'IF3', 'IF4', 'IF5', 'IF7'),
    new Block('IF2', 5, 'IF1', 'IF7'),
    new Block('IF3', 5, 'IF1', 'IF7'),
    new Block('IF4', 5, 'IF1'),
    new Block('IF5', 5, 'IF1'),
    new Block('IF6', 5),
    new Block('IF7', 5, 'IF1', 'IF2', 'IF3'),
    new Block('IF8', 5),
    new Block('IF9', 5),
    new Block('IF0', 5)
]
blocks.forEach(block => block.init(blocks))


const main = blocks => {
    console.log(blocks.map(it => it.name))
    const bars = []
    blocks.forEach((block, blockIndex) => {
        for (let blockNum = 0; blockNum < block.count; blockNum++) {
            for (let barIndex = 0; barIndex <= bars.length; barIndex++) {
                if (barIndex == bars.length) {
                    bars[barIndex] = [block]
                    console.log('creating new bar' ,barIndex, 'for', blockIndex, blockNum, block.name)
                    break // needed because of increased length
                } else {
                    //if (bars[barIndex].includes(block)) console.log('bar', barIndex, 'already contains', blockIndex, blockNum)
                    //if (block.blockedBlocks.every(blockedBlock => !bars[barIndex].includes(blockedBlock))) console.log(blockIndex, blockNum, 'doesn\'t like one of the containments in the bar', barIndex)
                    //if (bars[barIndex].every(testingBlock => !testingBlock.blockedBlocks.includes(block))) console.log('one of the containments of bar', barIndex, 'doesn\'t like', blockIndex, blockNum)
                    if (!bars[barIndex].includes(block) && 
                        block.blockedBlocks.every(blockedBlock => !bars[barIndex].includes(blockedBlock)) && 
                        bars[barIndex].every(testingBlock => !testingBlock.blockedBlocks.includes(block))
                        ) {
                        bars[barIndex].push(block)
                        break
                    }
                }
            }
        }
    })
    //console.log(bars)
    return bars
}

const arraySuffled = (toShuffel, begin = []) => {
    if (toShuffel.length == 1) return [begin.concat(toShuffel)]
    let returns = []
    for (let i = 0; i < toShuffel.length; i++) {
        returns = returns.concat(arraySuffled(toShuffel.slice(0, i).concat(toShuffel.slice(i+1)), begin.concat([toShuffel[i]])))
    }
    return returns
}

//const shuffledBlocks = arraySuffled(blocks)
console.log(blocks.map(it => it.name))
const shuffledBlocks = [blocks.sort(block => blocks.length - block.blockedBlocks.length)]
console.log(shuffledBlocks[0].map(it => it.name))
const resultBars = shuffledBlocks.map((blocks, index) => { return console.log(`generating ${index} of ${shuffledBlocks.length} (already has ${(100 * index / shuffledBlocks.length).toPrecision(4)}%)`), main(blocks) })
const bestResult = resultBars.reduce((a, b) => a.length <= b.length ? a : b)
console.log(bestResult.map(bar => bar.map(block => block.name)), bestResult.length, resultBars.map(x => x.length))
