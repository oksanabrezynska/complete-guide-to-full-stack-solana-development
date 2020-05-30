import React from "react"
import SEO from "../../../components/SEO"
import Label from "../../../components/Label"
import { SOL_VERSION } from "../constants"
import styles from "./index.module.css"
import { ROUTES_BY_CATEGORY } from "../routes"

function Home() {
  return (
    <div className={styles.component}>
      <SEO
        title={`Solidity by Example | ${SOL_VERSION}`}
        description="Learn smart contract programming using Solidity"
      />
      <h1 className={styles.header}>
        <a href="/">Solidity by Example {SOL_VERSION}</a>
      </h1>
      <div className={styles.main}>
        <p>
          an introduction to{" "}
          <a href="https://solidity.readthedocs.io">Solidity</a> with simple
          examples
        </p>

        {ROUTES_BY_CATEGORY.map(({ routes, title }, i) => (
          <div key={i}>
            {title && <h3>{title}</h3>}

            <ul className={styles.list}>
              {routes.map(({ path, title, breakingChanges }) => (
                <li className={styles.listItem} key={path}>
                  <a href={path}>{title}</a>
                  {breakingChanges && (
                    <div className={styles.label}>
                      <Label />
                    </div>
                  )}
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>
    </div>
  )
}

export default Home
